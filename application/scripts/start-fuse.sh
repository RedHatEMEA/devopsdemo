#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function startFuse()
{
    . ./common.sh

    # enable logging
    set +x

    ./kill-fuse.sh

    echo "Clearing down intermediate karaf data directories"
    rm -rf $FUSE_HOME/data/ $FUSE_HOME/instances/ $FUSE_HOME/processes/ $FUSE_HOME/lock

    echo "Launching Fuse"

    ($FUSE_HOME/bin/start $1)

    i=0.0
    c=0
    sleeptime=1

    echo -n "Waiting for Fuse to become available..."
    while [ $c -le 0 ]
    do
        sleep $sleeptime
        i=$(echo $sleeptime | bc)
        echo -n .
        c=$($FUSE_HOME/bin/client -u admin -p admin help 2> /dev/null| grep fabric:create | wc -l)
    done



FEATURES_PROJECT


    set -x



    if [ ${1} == "debug" ]
    then
        echo "Deploy services to standalone fuse container in debug mode"
        $FUSE_HOME/bin/client -u admin -p admin -r 60 "shell:source $FEATURES_PROJECT/karaf/deploy_non_fabric"

    else
        echo "Deploy services to fabric"
        $FUSE_HOME/bin/client -u admin -p admin -r 60 "fabric:create --new-user admin --new-user-password admin --wait-for-provisioning"
        $FUSE_HOME/bin/client -u admin -p admin -r 60 "shell:source $FEATURES_PROJECT/karaf/deploy"
        . $CURRENT_DIR/update-fabric-git.sh
        $FUSE_HOME/bin/client -u admin -p admin -r 60 "$CONTAINER_CREATE_CHILD_SCRIPT"

    fi
}




#
# main
#
options $@
if [ $? -ne 0 ]
then
   echo "USAGE: some flags may have errors"
   exit 1
fi


