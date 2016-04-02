#!/bin/bash

cd /home/ec2-user/BigDataTutorial
cd kafka
sudo -u ec2-user mvn package -Pfull
cd ../streaming
# sbt assembly
