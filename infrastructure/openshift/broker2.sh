#!/bin/bash -x

export CONF_ACTIONS=post_deploy

/tmp/openshift.sh

curl -u demo:demo -k https://localhost/console/applications &>/dev/null
oo-admin-ctl-domain -l demo -c create -n demo
