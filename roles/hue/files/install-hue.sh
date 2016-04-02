#!/bin/bash

: ${HUE_VERSION:=3.9.0}
: ${INSTALL_DIR:=/usr/local/}

install-hue() {
  yum -y install ant asciidoc cyrus-sasl-devel cyrus-sasl-gssapi gmp-devel gcc gcc-c++ krb5-devel libgmp3-dev libtidy libxml2-devel libxslt-devel mysql mysql-devel openssl-devel openldap-devel python-devel sqlite-devel wget
  echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment

  rm -rf hue* ${INSTALL_DIR}/hue*
  wget https://dl.dropboxusercontent.com/u/730827/hue/releases/${HUE_VERSION}/hue-${HUE_VERSION}.tgz
  tar -xzf hue-${HUE_VERSION}.tgz

  cd hue-${HUE_VERSION}
  make install

  id -u hue &>/dev/null || useradd hue
  chown -R hue:hue ${INSTALL_DIR}/hue
  HADOOP_USER_NAME=hdfs hdfs dfs -mkdir -p /user/hue
  HADOOP_USER_NAME=hdfs hdfs dfs -chown hue:hue /user/hue
  HADOOP_USER_NAME=hdfs hdfs dfs -mkdir -p /user/root
  HADOOP_USER_NAME=hdfs hdfs dfs -chown root:root /user/root

  NAMENODE=$(hdfs getconf -namenodes)
  HUE_INI=${INSTALL_DIR}/hue/desktop/conf/hue.ini
  RAND_TEXT=$(tr -dc a-z </dev/urandom | head -c 50)
  sed -i "s/fs_defaultfs=hdfs:\/\/localhost:8020/fs_defaultfs=hdfs:\/\/${NAMENODE}:8020/g" ${HUE_INI}
  sed -i "s/## webhdfs_url=http:\/\/localhost:50070\/webhdfs\/v1/webhdfs_url=http:\/\/${NAMENODE}:50070\/webhdfs\/v1/g" ${HUE_INI}
  sed -i "s/## resourcemanager_host=localhost/resourcemanager_host=${NAMENODE}/g" ${HUE_INI}
  sed -i "s/## resourcemanager_port=8032/resourcemanager_port=8050/g" ${HUE_INI}
  sed -i "s/## resourcemanager_api_url=http:\/\/localhost:8088/resourcemanager_api_url=http:\/\/${NAMENODE}:8088/g" ${HUE_INI}
  sed -i "s/## proxy_api_url=http:\/\/localhost:8088/proxy_api_url=http:\/\/${NAMENODE}:8088/g" ${HUE_INI}
  sed -i "s/# history_server_api_url=http:\/\/localhost:19888/history_server_api_url=http:\/\/${NAMENODE}:19888/g" ${HUE_INI}
  sed -i "s/## oozie_url=http:\/\/localhost:11000\/oozie/oozie_url=http:\/\/${NAMENODE}:11000\/oozie/g" ${HUE_INI}
  sed -i "s/## hive_server_host=localhost/hive_server_host=${NAMENODE}/g" ${HUE_INI}
  sed -i "s/## app_blacklist=/app_blacklist=impala,security/g" ${HUE_INI}
  sed -i "s/secret_key=/secret_key=${RAND_TEXT}/g" ${HUE_INI}
  # sed -i "s/http_port=8888/http_port=8080/g" ${HUE_INI} # cheap hack
  #sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 8080 -j REDIRECT --to-port 8888
  sudo -u hue {INSTALL_DIR}/hue/build/env/bin/supervisor -d
}

main(){
  install-hue
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
