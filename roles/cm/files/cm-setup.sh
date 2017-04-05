#!/bin/sh

# install & run cm
CDH_VERSION=5.8.3
if [ $# -eq 1 ]; then
  CDH_VERSION=$1
fi

echo "About to install CM ${CDH_VERSION}"
wget -O /etc/yum.repos.d/cloudera-manager.repo http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo
sed -i "s/cm\/.*\//cm\/$CDH_VERSION\//" /etc/yum.repos.d/cloudera-manager.repo
yum clean all
yum -y install oracle-j2sdk1.7
yum -y install cloudera-manager-server-db-2
service cloudera-scm-server-db start
service cloudera-scm-server start

# passwordless schema update
PASSWD=`sudo cat /var/lib/cloudera-scm-server-db/data/generated_password.txt | head -1`
echo "localhost:7432:*:cloudera-scm:${PASSWD}" > ~/.pgpass
chmod 0600 ~/.pgpass
psql -U cloudera-scm -p 7432 -h localhost -d postgres -a -f /vagrant/schema.sql

# install cm-api
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
python get-pip.py
pip install cm-api

# wait for cm to be responsive
CM_URL='http://localhost:7180'
wget $CM_URL
while [ $? -gt 0 ] 
do
  sleep 10
  echo "Waiting for Cloudera Manager to start, it can take few minutes."
  wget -q $CM_URL
done
echo "Cloudera Manager setup completed."
