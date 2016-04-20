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
}

main(){
  install-hue
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
