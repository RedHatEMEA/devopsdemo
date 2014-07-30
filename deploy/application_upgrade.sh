#!/bin/bash -ex

if [ -z $OS_AUTH_URL ] || [ -z $VERSION ] || [ -z $PREFIX ]; then
  echo "error: must set OpenStack credentials and inputs"
  exit 1
fi

get_ips() {
  eval $(utils/wait-stack.py dns)
  eval $(utils/wait-stack.py openshift)
  eval $(utils/wait-stack.py $PREFIX-database)
  eval $(utils/wait-stack.py $PREFIX-fabric)
}

prepare_fabric() {
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
}

upgrade_fabric() {
  eval $(utils/upgrade-fabric.py http://$ROOT_IP:8181/jolokia $PREFIX-monster $VERSION)
}

upgrade_openshift() {
  utils/deploy-openshift.py upgrade https://$BROKER_IP/broker/rest ${PREFIX}monster $CONTAINER_URL/cxf/ "http://10.33.11.12:8081/nexus/content/repositories/releases/com/redhat/ticketmonster/webapp/0.1-$VERSION/webapp-0.1-$VERSION.tar.gz"
}

get_ips
prepare_fabric
upgrade_fabric
upgrade_openshift
