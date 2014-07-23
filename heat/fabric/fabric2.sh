#!/bin/bash -x

FUSE_VERSION=${FUSE_VERSION:-jboss-fuse-6.1.0.redhat-379}

fuse_container_wait() {
  while true; do
    /usr/local/$FUSE_VERSION/bin/client "container-info $1" >/tmp/info
    if grep -q 'Alive:.*true' /tmp/info && grep -q 'Provision Status:.*success' /tmp/info
    then
      rm -f /tmp/info
      break
    fi
    sleep 5
  done
}

fuse_create_ensemble() {
  export JAVA_HOME=/usr/lib/jvm/jre-1.7.0/
  /usr/local/$FUSE_VERSION/bin/client "fabric:ensemble-add -f root2 root3"
}

fuse_container_wait root2
fuse_container_wait root3
fuse_create_ensemble
