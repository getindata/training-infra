#!/bin/bash

cd /tmp/BigDataTutorial
cd kafka
mvn package -Pfull
cd ../streaming
# sbt assembly
