#!/bin/bash

. /tmp/common.sh

export ZOOKEEPER=$(hostname):2181/kafka
## FOR HDP needs to be added /kafka , maybe bash if needed
##export ZOOKEEPER=$(hostname):2181/kafka
export KAFKA=$(hostname):9092

if [ -d "/opt/cloudera/parcels/KAFKA/bin" ]; then
  	cd /opt/cloudera/parcels/KAFKA/bin
   else
	cd /usr/hdp/current/kafka-broker/bin
fi
check_error_code

echo "Listing Kafka topics and creating"
#kafka-topics --list --zookeeper $ZOOKEEPER | grep lion
      if [ "`kafka-topics --list --zookeeper $ZOOKEEPER | grep lion`" == "lion" ]; then
    		kafka-topics --delete --topic=lion --zookeeper $ZOOKEEPER
      fi
kafka-topics --create --zookeeper $ZOOKEEPER --replication-factor 1 --partitions 1 --topic lion
check_error_code

echo "Preparing script for a test run"
LOCAL_IP=$(ping -c 1 $(hostname) | head -n 1 | awk '{print$3}' | cut -d"(" -f 2 | cut -d")" -f 1)
cd /tmp
sed -i 's/localhost/$LOCAL_IP/' /tmp/kafka_test.py
check_error_code

echo "Running tests"
python /tmp/kafka_test.py
check_error_code
