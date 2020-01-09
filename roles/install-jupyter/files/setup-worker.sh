#!/bin/sh
##
## Script to setup JupyterHub virtualenv
## on Cloudera installs using
## the Anaconda parcel
##

PARCELDIR=/opt/cloudera/parcels/Anaconda
ENVNAME=jupyterhub35

function runsetup() {
  PATH=${PARCELDIR}/bin:${PATH}
  conda create -y -n ${ENVNAME} python=3.5 anaconda
#  PATH=${PARCELDIR}/envs/${ENVNAME}/bin:${PATH}
#  pip install jupyterhub
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
