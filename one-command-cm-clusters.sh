#!/bin/bash

if [[ ! -f oregon.pem ]] ; then
    echo 'File "oregon.pem" is not there, aborting.'
    exit
fi

for config in $(ls -d ../clusters/*)
do
    ./one-command-cm-cluster.sh terraform ${config} oregon.pem
    #sleep 3m
    #./one-command-cm-cluster.sh cm ${config} oregon.pem
done
