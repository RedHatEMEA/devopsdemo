#!/usr/bin/env bash

echo "Killing all karaf processes"
ps -e -opid,command | grep "org.apache.karaf.main.Main" | grep -v grep | awk '{ print $1; }' | xargs kill  -KILL 2> /dev/null

exit 0