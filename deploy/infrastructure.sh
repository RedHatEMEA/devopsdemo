#!/bin/bash -ex

if [ -z $OS_AUTH_URL ]; then
  echo "error: must set OpenStack credentials"
  exit 1
fi

deploy_instances() {
  heat stack-create dns -e ../infrastructure/environment.yaml -f ../infrastructure/dns/template.yaml -P dns_nameservers=10.33.11.21 || true
  eval $(utils/wait-stack.py dns)
  heat stack-create openshift -e ../infrastructure/environment.yaml -f ../infrastructure/openshift/template.yaml -P dns_nameservers=$DNS_IP || true
  eval $(utils/wait-stack.py openshift)
}

deploy_instances
