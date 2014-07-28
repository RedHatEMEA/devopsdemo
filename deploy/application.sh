#!/bin/bash -ex

PREFIX=${PREFIX:-$(utils/rnd.py)}

if [ -z $OS_AUTH_URL ]; then
  echo "error: must set OpenStack credentials"
  exit 1
fi

get_dns_ip() {
  eval $(utils/wait-stack.py dns)
}

get_openshift_ip() {
  eval $(utils/wait-stack.py openshift)
}

deploy_app_instances() {
  heat stack-create $PREFIX-database -e ../infrastructure/environment.yaml -f ../infrastructure/database/template.yaml -P dns_nameservers=$DNS_IP || true
  heat stack-create $PREFIX-fabric -e ../infrastructure/environment.yaml -f ../infrastructure/fabric-lite/template.yaml -P dns_nameservers=$DNS_IP || true
  eval $(utils/wait-stack.py $PREFIX-database)
  eval $(utils/wait-stack.py $PREFIX-fabric)
}

deploy_app_fabric() {
  TMPDIR=$(mktemp -d)

  pushd $TMPDIR
  ping -c 1 $ROOT_IP &>/dev/null
  git clone -b 1.0 http://admin:admin@$ROOT_IP:8181/git/fabric
  popd

  mkdir $TMPDIR/fabric/fabric/profiles/ticketmonster.profile
  cp -a ../application/ticketmonster.profile/io.fabric8.agent.properties $TMPDIR/fabric/fabric/profiles/ticketmonster.profile
  cat >$TMPDIR/fabric/fabric/profiles/ticketmonster.profile/database.properties <<EOF
serverName = $DATABASE_IP
portNumber = 5432
databaseName = ticketmonster
user = admin
password = password
EOF

  pushd $TMPDIR
  cd fabric
  git add -A
  git commit -am ticketmonster
  git push
  popd

  rm -rf $TMPDIR

  eval $(utils/deploy-fabric.py http://$ROOT_IP:8181/jolokia ticketmonster $PREFIX-monster)
}

deploy_app_openshift() {
  utils/deploy-openshift.py https://$BROKER_IP/broker/rest ${PREFIX}monster $CONTAINER_URL/cxf/ "http://10.33.11.12:8081/nexus/content/repositories/snapshots/com/redhat/ticketmonster/webapp/0.1-SNAPSHOT/webapp-0.1-20140728.102124-4.tar.gz"
}

get_dns_ip
get_openshift_ip
deploy_app_instances
deploy_app_fabric
deploy_app_openshift
