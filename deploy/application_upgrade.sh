#!/bin/bash -ex

if [ -z $OS_AUTH_URL ] || [ -z $VERSION ] || [ -z $PREFIX ]; then
  echo "error: must set OpenStack credentials and inputs"
  exit 1
fi

FUSEVERSION=${VERSION//-/_}

get_ips() {
  eval $(utils/wait-stack.py ci)
  eval $(utils/wait-stack.py dns)
  eval $(utils/wait-stack.py openshift)
  eval $(utils/wait-stack.py $PREFIX-database)
  eval $(utils/wait-stack.py $PREFIX-fabric)
}

upgrade_fabric() {
  eval $(utils/upgrade-fabric.py http://$ROOT_IP:8181/jolokia restapi $FUSEVERSION)
  utils/upgrade-fabric.py http://$ROOT_IP:8181/jolokia emailroute $FUSEVERSION
}

upgrade_openshift() {
  utils/deploy-openshift.py upgrade https://$BROKER_IP/broker/rest ticketmonster $PREFIX redhat $CONTAINER_URL/cxf/ "http://$CI_IP/nexus/content/repositories/releases/com/redhat/ticketmonster/webapp/$VERSION/webapp-$VERSION.tar.gz"
}

get_ips
upgrade_fabric
upgrade_openshift
