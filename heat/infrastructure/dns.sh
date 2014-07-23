#!/bin/bash -x

export SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
export CONF_BIND_KEY=${CONF_BIND_KEY:-sM6LJvrKqb2R074G8vlGf7x02s9AsZ6RpldyQpHDqyI=}
export CONF_DOMAIN=${CONF_DOMAIN:-ose.saleslab.fab.redhat.com}

export CONF_NAMED_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export CONF_INSTALL_COMPONENTS=named
export CONF_FORWARD_DNS=true
export CONF_KEEP_HOSTNAME=true
export CONF_KEEP_NAMESERVERS=true

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime 

for CHANNEL in rhel-x86_64-server-6
do
  curl -so /etc/yum.repos.d/$CHANNEL.repo http://$SATELLITE_IP_ADDR:8085/$CHANNEL.repo
done

yum -y install ethtool

cat >>/etc/rc.local <<EOF
ethtool -K eth0 gso off
ethtool -K eth0 tso off
EOF

ethtool -K eth0 gso off
ethtool -K eth0 tso off

curl -so /tmp/openshift.sh https://raw.githubusercontent.com/openshift/openshift-extras/enterprise-2.1/enterprise/install-scripts/generic/openshift.sh
chmod 0755 /tmp/openshift.sh

/tmp/openshift.sh
