#!/bin/sh
##
## Script to setup JupyterHub
## on Cloudera installs using
## the Anaconda parcel
##

PARCELDIR=/opt/cloudera/parcels/Anaconda
ENVNAME=jupyterhub35
NODEVER=node-v4.4.5-linux-x64
NODETAR=https://nodejs.org/dist/v4.4.5/${NODEVER}.tar.xz
INITSCRIPT=https://gist.githubusercontent.com/briantwalter/d55f5c5a68f6ffba9be67d1b5b25ca75/raw/a4bf48a24caa6d8f11d7ce336936b9576b314577/jupyterhub

function runsetup() {
  PATH=${PARCELDIR}/bin:${PATH}
  conda create -y -n ${ENVNAME} python=3.5 anaconda
  curl ${NODETAR} | tar Jxvf - -C /tmp
  cp -R \
    /tmp/${NODEVER}/bin \
    /tmp/${NODEVER}/lib \
    /tmp/${NODEVER}/include \
    /tmp/${NODEVER}/share \
    /usr/local
  rm -rf /tmp/${NODEVER}
  /usr/local/bin/npm install -g configurable-http-proxy
  PATH=${PARCELDIR}/envs/${ENVNAME}/bin:${PATH}
  pip install jupyterhub
  if [ ! -d /etc/jupyterhub ];then
    mkdir /etc/jupyterhub
  fi
  jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py
  curl ${INITSCRIPT} > /etc/init.d/jupyterhub
  chmod 755 /etc/init.d/jupyterhub
  chkconfig jupyterhub on
}

# run as root
if [ $(whoami) != "root" ]; then
  echo "FATAL: Please run ${0} as root or use sudo"
  exit 1
fi
# make sure parcel is installed
if [ ! -d ${PARCELDIR} ]; then
  echo "FATAL: Please install Anaconda parcel in CM / CDH"
  echo "Follow the link http://docs.anaconda.com/anaconda/user-guide/tasks/integration/cloudera/"
  exit 1
fi
# if clean is the first arg then delete old env
if [ "${1}" == "clean" ] && [ -d ${PARCELDIR}/envs/${ENVNAME} ]; then
  rm -rf ${PARCELDIR}/envs/${ENVNAME}
  runsetup
else
  runsetup
fi
