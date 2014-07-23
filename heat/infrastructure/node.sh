#!/bin/bash -x

export SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
# CONF_NAMED_IP_ADDR
# CONF_BROKER_IP_ADDR
export CONF_BIND_KEY=${CONF_BIND_KEY:-sM6LJvrKqb2R074G8vlGf7x02s9AsZ6RpldyQpHDqyI=}
export CONF_DOMAIN=${CONF_DOMAIN:-ose.saleslab.fab.redhat.com}

export CONF_NODE_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export CONF_NODE_HOSTNAME=$(hostname).$CONF_DOMAIN
export CONF_INSTALL_COMPONENTS=node
export CONF_KEEP_HOSTNAME=true
export CONF_KEEP_NAMESERVERS=true
export CONF_NO_SCRAMBLE=true

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime 

for CHANNEL in rhel-x86_64-server-6 rhel-x86_64-server-6-rhscl-1 rhel-x86_64-server-6-ose-2.1-node rhel-x86_64-server-6-ose-2.1-jbosseap jbappplatform-6-x86_64-server-6-rpm jb-ews-2-x86_64-server-6-rpm
do
  curl -so /etc/yum.repos.d/$CHANNEL.repo http://$SATELLITE_IP_ADDR:8085/$CHANNEL.repo
done

yum -y install ethtool bind-utils

cat >>/etc/rc.local <<EOF
ethtool -K eth0 gso off
ethtool -K eth0 tso off
EOF

ethtool -K eth0 gso off
ethtool -K eth0 tso off

nsupdate -y HMAC-SHA256:$CONF_DOMAIN:$CONF_BIND_KEY <<EOF
server $CONF_NAMED_IP_ADDR
update delete $CONF_NODE_HOSTNAME A
update add $CONF_NODE_HOSTNAME 180 A $CONF_NODE_IP_ADDR
send
EOF

curl -so /tmp/openshift.sh https://raw.githubusercontent.com/openshift/openshift-extras/enterprise-2.1/enterprise/install-scripts/generic/openshift.sh
chmod 0755 /tmp/openshift.sh

/tmp/openshift.sh

sed -i -e 's/^cpu_cfs_quota_us=.*/cpu_cfs_quota_us=-1/' /etc/openshift/resource_limits.conf 

cat >/usr/libexec/openshift/cartridges/jbosseap/versions/shared/standalone/configuration/settings.base.xml <<EOF
<settings>
  <proxies>
    <proxy>
      <id>proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>10.33.11.12</host>
      <port>8080</port>
    </proxy>
  </proxies>
</settings>
EOF

cat >/usr/libexec/openshift/cartridges/jbossews/usr/versions/shared/configuration/settings.base.xml <<EOF
<settings>
  <proxies>
    <proxy>
      <id>proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>10.33.11.12</host>
      <port>8080</port>
    </proxy>
  </proxies>
</settings>
EOF

service ruby193-mcollective restart
