#!/bin/bash -x

export SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
# CONF_NAMED_IP_ADDR
export CONF_BIND_KEY=${CONF_BIND_KEY:-sM6LJvrKqb2R074G8vlGf7x02s9AsZ6RpldyQpHDqyI=}
export CONF_DOMAIN=${CONF_DOMAIN:-ose.saleslab.fab.redhat.com}

export CONF_BROKER_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export CONF_INSTALL_COMPONENTS=broker,activemq,datastore
export CONF_KEEP_HOSTNAME=true
export CONF_KEEP_NAMESERVERS=true
export CONF_NO_SCRAMBLE=true
export CONF_OPENSHIFT_PASSWORD1=demo

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

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6 rhel-x86_64-server-6-rhscl-1 rhel-x86_64-server-6-ose-2.1-infrastructure rhel-x86_64-server-6-ose-2.1-rhc
install_packages bind-utils

ose_register_dns broker.$CONF_DOMAIN A $CONF_BROKER_IP_ADDR
ose_register_dns activemq.$CONF_DOMAIN A $CONF_BROKER_IP_ADDR
ose_install
