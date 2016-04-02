#!/bin/bash

# TODO; run this on the edgenode
add-mysql-account() {
	user=$1
	mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'%' identified by '${user}';"
	mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'localhost' identified by '${user}';"
	mysql -p'root' -e "FLUSH PRIVILEGES;"
}


run-as-hdfs() {
	sudo -u hdfs "$@"
}


add-hdfs-account() {
	user=$1
	run-as-hdfs hadoop fs -mkdir /user/${user}
        run-as-hdfs hadoop fs -chown ${user} /user/${user}
}

drop-user-hive-db-tables() {
	user=$1
        run-as-hdfs hive -e "drop table if exists ${user}.stream;"
        run-as-hdfs hive -e "drop database if exists ${user};"
	run-as-hdfs hadoop fs -rmr /apps/hive/warehouse/${user}.db
}

create-user-hive-db() {
	user=$1
	run-as-hdfs hive -e "create database if not exists ${user};"
	run-as-hdfs hadoop fs -chown ${user} /apps/hive/warehouse/${user}.db
}


main() {
	user=$1
	add-mysql-account ${user}
	add-hdfs-account ${user}
	drop-user-hive-db-tables ${user}
	# create-user-hive-db ${user}
}


[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
