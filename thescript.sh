#!/bin/bash -x

PUBLIC_NET=ad47709d-dcc3-4b9a-bfcb-03dd7c0cf371
PRIVATE_NET=cec2b80c-030b-497b-945c-3b06d58de6f9
KEY_NAME=jminter

deploy_database() {
  #heat stack-create database -f heat/database/template.yaml -P "key_name=$KEY_NAME;public_net=$PUBLIC_NET;private_net=$PRIVATE_NET"
  eval $(utils/wait-stack.py database)
  DATABASE_IP=$root_ip
  # DATABASE_IP
}

deploy_fabric() {
  #heat stack-create fabric -f heat/fabric/template.yaml -P "key_name=$KEY_NAME;public_net=$PUBLIC_NET;private_net=$PRIVATE_NET"
  eval $(utils/wait-stack.py fabric)
  ROOT_IP=$root_ip
  # ROOT_IP

  TMPDIR=$(mktemp -d)
  pushd $TMPDIR
  git clone -b 1.0 http://admin:admin@$ROOT_IP:8181/git/fabric
  popd

  cp -a application/ticketmonster.profile $TMPDIR/fabric/fabric/profiles
  pushd $TMPDIR/fabric

  cat >fabric/profiles/ticketmonster.profile/database.properties <<EOF
serverName = $DATABASE_IP
portNumber = 5432
databaseName = ticketmonster
user = admin
password = password
EOF

  git add -A
  git commit -am ticketmonster
  git push

  popd
  rm -rf $TMPDIR

  eval $(utils/jolokia.py http://$ROOT_IP:8181/jolokia)
  # CXF_URL
}

deploy_openshift() {
  utils/openshift.py $1
}

deploy_database
deploy_fabric
deploy_openshift $CXF_URL/cxf/
