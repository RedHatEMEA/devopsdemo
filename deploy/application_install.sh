#!/bin/bash -ex

PREFIX=${PREFIX:-$(utils/rnd.py)}
VERSION=${VERSION:-11}

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
  heat stack-create $PREFIX-fabric -e ../infrastructure/environment.yaml -f ../infrastructure/fabric/template.yaml -P dns_nameservers=$DNS_IP || true
}

deploy_app_database() {
  eval $(utils/wait-stack.py $PREFIX-database)
  CONNSTRING="$DATABASE_IP:5432:ticketmonster:admin:password"
  grep -q $CONNSTRING ~/.pgpass || echo $CONNSTRING >>~/.pgpass 
  ping -c 2 $DATABASE_IP &>/dev/null || true
  psql -h $DATABASE_IP -U admin ticketmonster <../application/database/import.sql &>/dev/null
}

deploy_app_fabric() {
  eval $(utils/wait-stack.py $PREFIX-fabric)
  TMPDIR=$(mktemp -d)

  pushd $TMPDIR
  ping -c 2 $ROOT_IP &>/dev/null || true
  git clone -b 1.0 http://admin:admin@$ROOT_IP:8181/git/fabric
  cd fabric
  git branch $VERSION
  git checkout $VERSION
  popd

  mkdir $TMPDIR/fabric/fabric/profiles/ticketmonster.profile
  cp -a ../application/ticketmonster.profile/io.fabric8.agent.properties $TMPDIR/fabric/fabric/profiles/ticketmonster.profile
  sed -i -e "s/SNAPSHOT/$VERSION/g" $TMPDIR/fabric/fabric/profiles/ticketmonster.profile/io.fabric8.agent.properties
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
  git push --set-upstream origin $VERSION
  popd

  rm -rf $TMPDIR

  eval $(utils/deploy-fabric.py http://$ROOT_IP:8181/jolokia ticketmonster $PREFIX-monster $VERSION)
}

deploy_app_openshift() {
  utils/deploy-openshift.py create https://$BROKER_IP/broker/rest ${PREFIX}monster $CONTAINER_URL/cxf/ "http://10.33.11.12:8081/nexus/content/repositories/releases/com/redhat/ticketmonster/webapp/0.1-$VERSION/webapp-0.1-$VERSION.tar.gz"
}

get_dns_ip
get_openshift_ip
deploy_app_instances
deploy_app_database
deploy_app_fabric
deploy_app_openshift
