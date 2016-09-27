#!/bin/bash

. common.sh

echo "Downloading StreamRock log file"
wget -q https://dl.dropboxusercontent.com/u/16026724/logs/lion.tsv -O /tmp/lion.tsv
check_error_code

echo "Uploading log file"
hadoop fs -put -f /tmp/lion.tsv /incoming/logs/upload
check_error_code

echo "Checking connection to Hive"
hive -e "show databases;" >> /dev/null
check_error_code

echo "Drop table if exist"
hive -e "DROP TABLE lion.logs;"
check_error_code

#echo "Hive create database"
#hive -e "CREATE DATABASE lion;"
#check_error_code

echo "Hive create table"
hive -e "CREATE TABLE \`lion.logs\`(
  \`ts\` string,
  \`host\` string,
  \`userid\` smallint,
  \`eventtype\` string,
  \`itemid\` smallint,
  \`duration\` tinyint)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
TBLPROPERTIES (
  'transient_lastDdlTime'='1474542637')"
check_error_code

echo "Hive importing data to table"
hive -e "LOAD DATA INPATH '/incoming/logs/upload/lion.tsv' OVERWRITE INTO TABLE lion.logs"
check_error_code

echo "Simple select from lion.logs"
hive -e "SELECT itemid, count(*) AS cnt
FROM lion.logs
WHERE eventtype = 'SongPlayed'
GROUP BY itemid
ORDER BY cnt DESC
LIMIT 10;"
check_error_code

echo "Simple select from lion.logs with join default.track"
hive -e "SELECT * FROM tiger.logs l 
JOIN default.track t ON l.itemId = t.id;"
check_error_code
