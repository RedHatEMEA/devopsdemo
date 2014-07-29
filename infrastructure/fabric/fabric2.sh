#!/bin/bash -x

FUSE_VERSION=${FUSE_VERSION:-jboss-fuse-6.1.0.redhat-379}
FUSE_USER=ec2-user

fuse_container_wait() {
  su - $FUSE_USER <<EOF
while true; do
  /usr/local/$FUSE_VERSION/bin/client "container-info $1" >/tmp/info
  if grep -q 'Alive:.*true' /tmp/info && grep -q 'Provision Status:.*success' /tmp/info
  then
    rm -f /tmp/info
    break
  fi
  sleep 5
done
EOF
}

fuse_create_ensemble() {
  su - $FUSE_USER <<EOF
export JAVA_HOME=/usr/lib/jvm/jre-1.7.0/
/usr/local/$FUSE_VERSION/bin/client "fabric:ensemble-add -f root2 root3"
EOF
}

fuse_container_wait root2
fuse_container_wait root3
fuse_create_ensemble
