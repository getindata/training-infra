#!/bin/bash

. /tmp/common.sh

echo "Checking if HDFS is readable"
hadoop fs -ls / >> /dev/null
check_error_code

echo "Checking if HDFS is writable"
TEMP_FILE=$(mktemp)
hadoop fs -put $TEMP_FILE /tmp
check_error_code
hadoop fs -rm $TEMP_FILE
rm $TEMP_FILE

echo "Creating directory /incoming/logs/upload"
hadoop fs -mkdir -p  /incoming/logs/upload
hadoop fs -chmod 777 /incoming/logs/upload
check_error_code
