#!/bin/sh

PKG=$1
# DEBIAN_FRONTEND="noninteractive"
# export DEBIAN_FRONTEND

#if dpkg --status $PKG > /dev/null 2>&1 ; then
#    exit 0
#fi

echo "Installing $PKG..."
(yum makecache fast && yum -y install $PKG) > /dev/null 2>&1
exit $?
