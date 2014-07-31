#!/usr/bin/env bash

# Setup the fuse home varilable
if [ -z "$FUSE_HOME" ]; then
    if [ -e fuse.home.properties ]; then
       export FUSE_HOME=$(cat fuse.home.properties)
    else
       cwd=$(pwd)
       echo "ERROR : The \$FUSE_HOME environemnt variable is not set. Set it or create a fuse.home.properties in $cwd with the path to your fuse installation"
       exit 1
    fi
fi


export FEATURES_PROJECT=$(cat features.properties)

# Setup the main deploy script
if [ -z "$FUSE_HOME" ]; then
    if [ -e fuse.home.properties ]; then
       export FUSE_HOME=$(cat fuse.home.properties)
    else
       cwd=$(pwd)
       echo "ERROR : The \$FUSE_HOME environemnt variable is not set. Set it or create a fuse.home.properties in $cwd with the path to your fuse installation"
       exit 1
    fi
fi

echo "Fuse Home set to : $FUSE_HOME"

if [ -z "${M2_REPO}" ]
 then
    export M2_REPO="~/.m2"
    echo "setting M2_REPO to ${M2_REPO}"
fi

if [ -z "${KARAF_SCRIPT_LOCATION}" ]
 then
    export KARAF_SCRIPT_LOCATION=$(dirname $(pwd))
    echo "setting KARAF_SCRIPT_LOCATION to ${KARAF_SCRIPT_LOCATION}"
fi

# Modify the default username and password to be admin, admin for a fresh fuse install
pushd $FUSE_HOME/etc
grep -rl "#admin" $FUSE_HOME/etc/users.properties | xargs sed -i '' "s/#admin=admin,admin/admin=admin,admin/g"

# Get the version of the fuse container and print it out for debugging purposes
export fuseVersion=$(grep -oEi "6.1.0.redhat-([0-9]+)" $FUSE_HOME/readme.txt |  grep -oEi [0-9][0-9][0-9])
echo "Using Fuse 6.1.0.redhat-$fuseVersion"

popd

