#!/bin/bash -ex

if [ -z $OS_AUTH_URL ]; then
  echo "error: must set OpenStack credentials"
  exit 1
fi

neutron security-group-delete devopsdemo || true
neutron security-group-create devopsdemo --description devopsdemo

neutron security-group-rule-create --direction ingress --protocol icmp devopsdemo
neutron security-group-rule-create --direction ingress --protocol tcp devopsdemo
neutron security-group-rule-create --direction ingress --protocol udp devopsdemo

utils/repo_setup.sh
