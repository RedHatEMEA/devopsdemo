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

nova keypair-add --pub_key ~/.ssh/id_rsa.pub $USER || true

export PUBLIC_NET=$(neutron net-list --router:external True -f csv -c id --quote none |tail -1)

envsubst <../infrastructure/environment.yaml.example >../infrastructure/environment.yaml
