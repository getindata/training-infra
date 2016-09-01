#!/bin/bash

generate-user-password() {
	user=$1
	suffix=$2
	echo "${user}$(suffix)"
}

set-unix-password() {
	user=$1
	suffix=$2
	password=$(generate-user-password ${user} ${suffix})
	echo ${user}:${password} | sudo chpasswd
}

# TODO; run this on the edgenode
add-mysql-account() {
	user=$1
	suffix=$2
	password=$(generate-user-password ${user} ${suffix})
	mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'%' identified by '${password}';"
	mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'localhost' identified by '${password}';"
	mysql -p'root' -e "GRANT ALL PRIVILEGES ON *.* TO '${user}'@'$(hostname)' identified by '${password}';"
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
	run-as-hdfs hadoop fs -rm -r -f /apps/hive/warehouse/${user}.db /user/hive/warehouse/${user}.db
}


create-user-hive-db() {
	user=$1
	run-as-hdfs hive -e "create database if not exists ${user};"
	run-as-hdfs hadoop fs -chown ${user} /*/hive/warehouse/${user}.db
}


main() {
	user=$1
	suffix=$2
	set-unix-password ${user} ${suffix}
	add-mysql-account ${user} ${suffix}
	add-hdfs-account ${user} ${suffix}

	#drop-user-hive-db-tables ${user}
	#create-user-hive-db ${user}
}


[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
