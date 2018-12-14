#!/bin/bash

mysql -u root -e "create database if not exists streamrock"
mysql -e "drop table if exists streamrock.concert"
mysql -e "CREATE TABLE streamrock.concert \
                (id INT NOT NULL PRIMARY KEY, artist VARCHAR(50) NOT NULL, day TIMESTAMP DEFAULT NOW(), city VARCHAR(50), location VARCHAR(25));"

mysql -p'root' -e "load data local infile '/tmp/concerts.tsv' \
                into table streamrock.concert fields terminated by '\t' lines terminated by '\n' \
                (id, artist, day, city, location)"

mysql -e "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' identified by 'admin';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'$(hostname)' identified by 'admin';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' identified by 'admin';"

mysql -e "CREATE USER IF NOT EXISTS 'ec2-user'@'%' IDENTIFIED BY 'ec2-user'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'%' identified by 'ec2-user';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'$(hostname)' identified by 'ec2-user';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'localhost' identified by 'ec2-user';"

mysql -e "FLUSH PRIVILEGES;"
