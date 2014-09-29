#!/bin/bash -ex

if [ -z $OS_AUTH_URL ]; then
  echo "error: must set OpenStack credentials"
  exit 1
fi

if ! [ -e ~/.ssh/id_rsa ]; then
  mkdir -p -m 0700 ~/.ssh
  ssh-keygen -f ~/.ssh/id_rsa -N ""
fi

nova keypair-add --pub_key ~/.ssh/id_rsa.pub $USER || true

export PUBLIC_NET=$(neutron net-list --router:external True -f csv -c id --quote none |tail -1)

envsubst <../infrastructure/environment.yaml.example >../infrastructure/environment.yaml
