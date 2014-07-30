#!/usr/bin/env bash

rm -fr git-repo
mkdir git-repo
pushd git-repo
git clone -b 1.0 http://admin:admin@localhost:8181/git/fabric
popd
cp ./local.profile/*.properties ./git-repo/fabric/fabric/profiles/ticketmonster.profile
pushd git-repo/fabric
git add .
git commit -am "Added new properties"
git push origin 1.0
