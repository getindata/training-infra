#!/bin/sh

cm_status_file=/tmp/cm-setup.log

# install & run cm
CDH_VERSION=5.8.3
if [ $# -eq 1 ]; then
  CDH_VERSION=$1
fi

echo "About to install CM ${CDH_VERSION}" > ${cm_status_file}
wget -O /etc/yum.repos.d/cloudera-manager.repo http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo
sed -i "s/cm\/.*\//cm\/$CDH_VERSION\//" /etc/yum.repos.d/cloudera-manager.repo
yum clean all

echo "Installing dependencies" >> ${cm_status_file}
yum -y install oracle-j2sdk1.7
yum -y install cloudera-manager-server-db-2

echo "Starting Cloudera SCM db and server" >> ${cm_status_file}
service cloudera-scm-server-db start
service cloudera-scm-server start

echo "Passwordless schema update" >> ${cm_status_file}
PASSWD=`sudo cat /var/lib/cloudera-scm-server-db/data/generated_password.txt | head -1`
echo "localhost:7432:*:cloudera-scm:${PASSWD}" > ~/.pgpass
chmod 0600 ~/.pgpass
psql -U cloudera-scm -p 7432 -h localhost -d postgres -a -f /tmp/schema.sql

echo "Install cm-api" >> ${cm_status_file}
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
python get-pip.py
pip install cm-api

echo "Wait for cm to be responsive" >> ${cm_status_file}
CM_URL='http://localhost:7180'
wget $CM_URL
while [ $? -gt 0 ] 
do
  sleep 20
  echo "Waiting for Cloudera Manager to start, it can take few minutes." >> ${cm_status_file}
  wget -q $CM_URL
done
echo "Cloudera Manager setup completed." >> ${cm_status_file}
