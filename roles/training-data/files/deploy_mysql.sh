#!/bin/bash

mysqladmin -u root password root

mysql -p'root' -e "create database if not exists streamrock"
mysql -p'root' -e "drop table if exists streamrock.concert"
mysql -p'root' -e "CREATE TABLE streamrock.concert \
                (id INT NOT NULL PRIMARY KEY, artist VARCHAR(50) NOT NULL, day TIMESTAMP DEFAULT NOW(), city VARCHAR(50), location VARCHAR(25));"

mysql -p'root' -e "load data local infile 'concerts.tsv' \
                into table streamrock.concert fields terminated by '\t' lines terminated by '\n' \
                (id, artist, day, city, location)"

mysql -p'root' -e "CREATE USER IF NOT EXISTS 'ec2-user'@'%' IDENTIFIED BY 'ec2-user'"
mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'%' identified by 'ec2-user';"
mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'localhost' identified by 'ec2-user';"
mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO 'ec2-user'@'$(hostname)' identified by 'ec2-user';"

mysql -p'root' -e "FLUSH PRIVILEGES;"
