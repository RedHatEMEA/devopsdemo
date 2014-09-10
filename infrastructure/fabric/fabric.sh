#!/bin/bash -x

SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
PROXY_IP_ADDR=${PROXY_IP_ADDR:-10.33.11.12}
FUSE_VERSION=${FUSE_VERSION:-jboss-fuse-6.1.0.redhat-379}

LOCAL_IP_ADDR=$(ifconfig eth0 | sed -ne '/inet addr:/ { s/.*inet addr://; s/ .*//; p }')
FLOATING_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
FUSE_USER=cloud-user

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
  python -u /usr/bin/yum -y install $*
}

disable_firewall() {
  service iptables stop
  chkconfig iptables off
}

fuse_fix_hosts() {
  echo "$LOCAL_IP_ADDR $(hostname)" >>/etc/hosts
}

fuse_install() {
  curl -so /tmp/$FUSE_VERSION.zip http://$PROXY_IP_ADDR/jboss-fuse-medium-6.1.0.redhat-379.zip
  unzip -q /tmp/$FUSE_VERSION.zip -d /usr/local
}

fuse_create_admin_user() {
  echo -e "\n$1=$2,admin" >>/usr/local/$FUSE_VERSION/etc/users.properties 
}

fuse_set_container_name() {
  sed -i -e "s/karaf.name=root/karaf.name=$1/" /usr/local/$FUSE_VERSION/etc/system.properties
}

fuse_set_nexus() {
  sed -i -e "/^org.ops4j.pax.url.mvn.repositories=/,/[^\]$/ d; $ a\
org.ops4j.pax.url.mvn.repositories=http://$CONF_CI_IP_ADDR:8081/nexus/content/groups/public@id=mirror.repo" /usr/local/$FUSE_VERSION/fabric/import/fabric/configs/versions/1.0/profiles/default/io.fabric8.agent.properties
}

fuse_disable_indexer() {
  sed -i -e '/<feature>hawtio-maven-indexer<\/feature>/ d' /usr/local/$FUSE_VERSION/system/io/hawt/hawtio-karaf/1.2-redhat-379/hawtio-karaf-1.2-redhat-379-features.xml
}

fuse_chown() {
  chown -R $FUSE_USER:$FUSE_USER /usr/local/$FUSE_VERSION
}

fuse_start() {
  su - $FUSE_USER <<EOF
export JAVA_HOME=/usr/lib/jvm/jre-1.7.0

/usr/local/$FUSE_VERSION/bin/start
while ! /usr/local/$FUSE_VERSION/bin/client </dev/null &>/dev/null
do
  sleep 5
done
EOF
}

fuse_create_fabric() {
  su - $FUSE_USER <<EOF
/usr/local/$FUSE_VERSION/bin/client "fabric:create --wait-for-provisioning --resolver manualip --manual-ip $FLOATING_IP_ADDR --profile fabric"
/usr/local/$FUSE_VERSION/bin/client "container-create-child --profile mq-amq root broker"
EOF
}

fuse_join_fabric() {
  su - $FUSE_USER <<EOF
/usr/local/$FUSE_VERSION/bin/client "fabric:join -f --zookeeper-password admin --resolver manualip --manual-ip $FLOATING_IP_ADDR $1"
EOF
}

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6
install_packages java-1.7.0-openjdk unzip

disable_firewall

fuse_fix_hosts
fuse_install
fuse_create_admin_user admin admin
fuse_set_container_name $CONF_NODE
fuse_set_nexus
fuse_disable_indexer
fuse_chown
fuse_start

if [ $CONF_NODE = root ]
then
  fuse_create_fabric
else
  fuse_join_fabric $CONF_NODE1_IP_ADDR
fi
