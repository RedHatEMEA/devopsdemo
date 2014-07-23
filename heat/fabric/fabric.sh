#!/bin/bash -x

SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}
PROXY_IP_ADDR=${PROXY_IP_ADDR:-10.33.11.12}
PROXY_PORT=${PROXY_PORT:-8080}
FUSE_VERSION=${FUSE_VERSION:-jboss-fuse-6.1.0.redhat-379}

LOCAL_IP_ADDR=$(ifconfig eth0 | sed -ne '/inet addr:/ { s/.*inet addr://; s/ .*//; p }')
FLOATING_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

set_tz() {
  ln -sf /usr/share/zoneinfo/$1 /etc/localtime 
}

register_channels() {
  for CHANNEL in $*
  do
    curl -so /etc/yum.repos.d/$CHANNEL.repo http://$SATELLITE_IP_ADDR:8085/$CHANNEL.repo
  done
}

fix_gso() {
  cat >>/etc/rc.local <<EOF
ethtool -K eth0 gso off
ethtool -K eth0 tso off
EOF

  ethtool -K eth0 gso off
  ethtool -K eth0 tso off
}

disable_firewall() {
  service iptables stop
  chkconfig iptables off
}

install_packages() {
  yum -y install $*
}

fuse_fix_hosts() {
  echo "$LOCAL_IP_ADDR $(hostname)" >>/etc/hosts
}

fuse_set_proxy() {
  mkdir $HOME/.m2
  cat >$HOME/.m2/settings.xml <<EOF
<settings>
  <proxies>
    <proxy>
      <id>proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>$PROXY_IP_ADDR</host>
      <port>$PROXY_PORT</port>
    </proxy>
  </proxies>
</settings>
EOF

  curl -so /tmp/cacert http://$PROXY_IP_ADDR/cacert
  keytool -import -alias MyCA -file /tmp/cacert -keystore /etc/pki/java/cacerts -storepass changeit -noprompt
  rm -f /tmp/cacert
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

fuse_start() {
  export JAVA_HOME=/usr/lib/jvm/jre-1.7.0

  /usr/local/$FUSE_VERSION/bin/start
  while ! /usr/local/$FUSE_VERSION/bin/client </dev/null &>/dev/null
  do
    sleep 5
  done
}

fuse_create_fabric() {
  /usr/local/$FUSE_VERSION/bin/client "fabric:create --wait-for-provisioning --resolver manualip --manual-ip $FLOATING_IP_ADDR --profile fabric"
}

fuse_join_fabric() {
  /usr/local/$FUSE_VERSION/bin/client "fabric:join -f --zookeeper-password admin --resolver manualip --manual-ip $FLOATING_IP_ADDR $1"
}

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6
install_packages java-1.7.0-openjdk unzip

disable_firewall

fuse_fix_hosts
fuse_set_proxy
fuse_install
fuse_create_admin_user admin admin
fuse_set_container_name $CONF_NODE
fuse_start

if [ $CONF_NODE = root ]
then
  fuse_create_fabric
else
  fuse_join_fabric $CONF_NODE1_IP_ADDR
fi
