#!/bin/bash -ex

PREFIX=${PREFIX:-$(utils/rnd.py)}
VERSION=${VERSION:-0.1-SNAPSHOT}
LITE=${LITE:-yes}

FUSEVERSION=${VERSION//-/.}

if [ -z $OS_AUTH_URL ]; then
  echo "error: must set OpenStack credentials"
  exit 1
fi

get_ci_ip() {
  eval $(utils/wait-stack.py ci)
}

get_dns_ip() {
  eval $(utils/wait-stack.py dns)
}

get_openshift_ip() {
  eval $(utils/wait-stack.py openshift)
}

deploy_app_instances() {
  heat stack-create $PREFIX-database -e ../infrastructure/environment.yaml -f ../infrastructure/database/template.yaml -P dns_nameservers=$DNS_IP || true
  if [ $LITE = yes ]
  then 
    heat stack-create $PREFIX-fabric -e ../infrastructure/environment.yaml -f ../infrastructure/fabric-lite/template.yaml -P "dns_nameservers=$DNS_IP;ci_ip_address=$CI_IP" || true
  else
    heat stack-create $PREFIX-fabric -e ../infrastructure/environment.yaml -f ../infrastructure/fabric/template.yaml -P "dns_nameservers=$DNS_IP;ci_ip_address=$CI_IP" || true
  fi
}

deploy_app_database() {
  eval $(utils/wait-stack.py $PREFIX-database)
  PGPASSWORD=password psql -h $DATABASE_IP -U admin ticketmonster <../application/database/import.sql &>/dev/null
}

deploy_app_fabric() {
  eval $(utils/wait-stack.py $PREFIX-fabric)
  TMPDIR=$(mktemp -d)

  pushd $TMPDIR
  git clone -b 1.0 http://admin:admin@$ROOT_IP:8181/git/fabric
  cd fabric
  git branch $FUSEVERSION
  git checkout $FUSEVERSION
  popd

  cp -a ../application/profiles/* $TMPDIR/fabric/fabric/profiles
  for FILE in $TMPDIR/fabric/fabric/profiles/ticketmonster/*/io.fabric8.agent.properties
  do
    sed -i -e "s/0.1-SNAPSHOT/$VERSION/g" $FILE
  done
  cat >$TMPDIR/fabric/fabric/profiles/ticketmonster/rest.profile/database.properties <<EOF
serverName = $DATABASE_IP
portNumber = 5432
databaseName = ticketmonster
user = admin
password = password
EOF
  cat >$TMPDIR/fabric/fabric/profiles/ticketmonster/emailroute.profile/email.properties <<EOF
smtp.email.server = 10.4.122.10
EOF

  pushd $TMPDIR
  cd fabric
  git add -A
  git commit -am ticketmonster
  git push --set-upstream origin $FUSEVERSION
  popd

  rm -rf $TMPDIR

  eval $(utils/deploy-fabric.py http://$ROOT_IP:8181/jolokia ticketmonster-rest restapi $FUSEVERSION)
  utils/deploy-fabric.py http://$ROOT_IP:8181/jolokia ticketmonster-emailroute emailroute $FUSEVERSION
}

deploy_app_openshift() {
  if [ $VERSION = "0.1-SNAPSHOT" ]; then
    URL=$(curl -sI "http://$CI_IP/nexus/service/local/artifact/maven/redirect?r=snapshots&g=com.redhat.ticketmonster&a=webapp&v=$VERSION&e=tar.gz" | sed -ne '/^Location: / { s/^Location: //; p; }' | tr -d '\r\n')
  else
    URL="http://$CI_IP/nexus/content/repositories/releases/com/redhat/ticketmonster/webapp/$VERSION/webapp-$VERSION.tar.gz"
  fi

  ( ldapadd -H ldap://dns.demo/ -D 'cn=Manager,dc=demo' -w redhat <<EOF
dn: cn=$PREFIX,ou=Users,dc=demo
cn: $PREFIX
objectClass: person
objectClass: top
sn: $PREFIX
userPassword: {SSHA}j0IDrK07yBa6qo0Ofh1L2M8kaVrPtn6f
EOF
) || true

  utils/deploy-openshift.py create https://$BROKER_IP/broker/rest ticketmonster $PREFIX redhat $CONTAINER_URL/cxf/ "$URL"
}

( cd ../infrastructure && ./make.sh )
get_ci_ip
get_dns_ip
get_openshift_ip
deploy_app_instances
deploy_app_database
deploy_app_fabric
deploy_app_openshift
