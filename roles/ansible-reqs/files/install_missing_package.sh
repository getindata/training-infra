#!/bin/sh
PKG=$1

if [ -f /etc/debian_version ]; then
  OS_FAMILY="Debian"
  PKG=$1
  DEBIAN_FRONTEND="noninteractive"
  export DEBIAN_FRONTEND
  echo "Installing $PKG..."
  (apt-get update && apt-get -y install $PKG) > /dev/null 2>&1
  exit $?
elif [ -f /etc/redhat-release ]; then
  OS_FAMILY="RedHat"
  echo "Installing $PKG..."
  (yum makecache fast && yum -y install $PKG) > /dev/null 2>&1
  exit $?
else
  echo "Cannot recognize the OS family"
  exit 1
fi

