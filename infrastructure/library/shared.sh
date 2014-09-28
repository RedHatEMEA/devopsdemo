. config.sh

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

fix_hosts() {
  echo "$LOCAL_IP_ADDR $(hostname)" >>/etc/hosts
}

register_dns() {
  nsupdate -y HMAC-SHA256:devopsdemo:$BIND_KEY <<EOF
server $DNS_IP_ADDR
update delete $1 $2
update add $1 180 $2 $3
send
EOF
}

LOCAL_IP_ADDR=$(ifconfig eth0 | sed -ne '/inet addr:/ { s/.*inet addr://; s/ .*//; p }')
while true; do
  FLOATING_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
  if [ $FLOATING_IP_ADDR ]; then
    break
  fi

  sleep 1
done
DNS_IP_ADDR=$(sed -ne '/nameserver/ {s/nameserver //; p; }' /etc/resolv.conf)

fix_gso
fix_hosts
set_tz Europe/London
