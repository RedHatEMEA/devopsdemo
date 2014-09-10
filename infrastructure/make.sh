#!/bin/bash -e

for i in */*; do
  [ -d $i ] && ( cd $i && tar -chzf ../$(basename $i).tgz * )
done

true
