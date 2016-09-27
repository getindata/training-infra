#!/bin/bash

. common.sh

spark-submit --master yarn-client --driver-memory 512m --executor-memory 256m --num-executors 3 --conf spark.ui.port=4062 spark-cmd-1.py
check_error_code

spark-submit --master yarn-client --driver-memory 512m --executor-memory 256m --num-executors 3 --conf spark.ui.port=4062 spark-cmd-2.py
check_error_code

spark-submit --master yarn-client --driver-memory 512m --executor-memory 256m --num-executors 3 --conf spark.ui.port=4062 spark-cmd-3.py
check_error_code
