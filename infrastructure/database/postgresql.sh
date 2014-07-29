#!/bin/bash -x

SATELLITE_IP_ADDR=${SATELLITE_IP_ADDR:-10.33.11.10}

LOCAL_IP_ADDR=$(ifconfig eth0 | sed -ne '/inet addr:/ { s/.*inet addr://; s/ .*//; p }')
FLOATING_IP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

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

disable_firewall() {
  service iptables stop
  chkconfig iptables off
}

postgres_configure() {
  chkconfig postgresql on
  service postgresql initdb

  echo "listen_addresses = '*'" >>/var/lib/pgsql/data/postgresql.conf
  cat >>/var/lib/pgsql/data/pg_hba.conf <<'EOF'
host all postgres 0.0.0.0/0 reject
host all all 0.0.0.0/0 md5
EOF

  service postgresql start
}

db_create() {
  su - postgres <<EOF
createuser -s $2
createdb -O $2 $1
echo "ALTER USER $2 PASSWORD '$3'" | psql
EOF
}

fix_gso
set_tz Europe/London
register_channels rhel-x86_64-server-6
install_packages postgresql-server

disable_firewall
postgres_configure
db_create ticketmonster admin password
