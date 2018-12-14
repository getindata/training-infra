#!/bin/bash

: ${INSTALL_DIR:=/usr/local/}

onboard-hue-user() {
  id -u hue &>/dev/null || useradd hue
  chown -R hue:hue ${INSTALL_DIR}/hue
  HADOOP_USER_NAME=hdfs hdfs dfs -mkdir -p /user/hue
  HADOOP_USER_NAME=hdfs hdfs dfs -chown hue:hue /user/hue
}

main(){
  onboard-hue-user
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
