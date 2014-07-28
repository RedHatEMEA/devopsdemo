#!/bin/bash -x

# CONF_BROKER_IP_ADDR

export SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
export PROXY_IP_ADDR=${PROXY_IP_ADDR:-10.33.11.12}
export CONF_BIND_KEY=${CONF_BIND_KEY:-sM6LJvrKqb2R074G8vlGf7x02s9AsZ6RpldyQpHDqyI=}
export CONF_DOMAIN=${CONF_DOMAIN:-ose.saleslab.fab.redhat.com}

export CONF_NODE_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export CONF_NAMED_IP_ADDR=$(sed -ne '/nameserver/ {s/nameserver //; p; }' /etc/resolv.conf)
export CONF_NODE_HOSTNAME=$(hostname).$CONF_DOMAIN
export CONF_INSTALL_COMPONENTS=node
export CONF_KEEP_HOSTNAME=true
export CONF_KEEP_NAMESERVERS=true
export CONF_NO_SCRAMBLE=true

fix_gso() {
  cat >>/etc/rc.local <<EOF
ethtool -K eth0 gso off
ethtool -K eth0 tso off
EOF

  ethtool -K eth0 gso off
  ethtool -K eth0 tso off
}

set_tz() {
  ln -sf /usr/share/zoneinfo/$1 /etc/localtime 
}

register_channels() {
  for CHANNEL in $*
  do
    curl -so /etc/yum.repos.d/$CHANNEL.repo http://$SATELLITE_IP_ADDR:8085/$CHANNEL.repo
  done
}

install_packages() {
  yum -y install $*
}

ose_register_dns() {
  nsupdate -y HMAC-SHA256:$CONF_DOMAIN:$CONF_BIND_KEY <<EOF
server $CONF_NAMED_IP_ADDR
update delete $1 $2
update add $1 180 $2 $3
send
EOF
}

ose_install() {
  curl -so /tmp/openshift.sh https://raw.githubusercontent.com/openshift/openshift-extras/enterprise-2.1/enterprise/install-scripts/generic/openshift.sh
  chmod 0755 /tmp/openshift.sh

  /tmp/openshift.sh
}

ose_node_configure() {
  sed -i -e 's/^cpu_cfs_quota_us=.*/cpu_cfs_quota_us=-1/' /etc/openshift/resource_limits.conf

  cat >/usr/libexec/openshift/cartridges/jbosseap/versions/shared/standalone/configuration/settings.base.xml <<EOF
<settings>
  <mirrors>
    <mirror>
      <mirrorOf>*</mirrorOf>
      <url>http://$PROXY_IP_ADDR:8081/nexus/content/groups/public</url>
      <id>mirror</id>
    </mirror>
  </mirrors>
</settings>
EOF

  cat >/usr/libexec/openshift/cartridges/jbossews/usr/versions/shared/configuration/settings.base.xml <<EOF
<settings>
  <mirrors>
    <mirror>
      <mirrorOf>*</mirrorOf>
      <url>http://$PROXY_IP_ADDR:8081/nexus/content/groups/public</url>
      <id>mirror</id>
    </mirror>
  </mirrors>
</settings>
EOF

  service ruby193-mcollective restart
}

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6 rhel-x86_64-server-6-rhscl-1 rhel-x86_64-server-6-ose-2.1-node rhel-x86_64-server-6-ose-2.1-jbosseap jbappplatform-6-x86_64-server-6-rpm jb-ews-2-x86_64-server-6-rpm
install_packages bind-utils

ose_register_dns $CONF_NODE_HOSTNAME A $CONF_NODE_IP_ADDR
ose_install
ose_node_configure
