#!/bin/bash

run-as-hdfs() {
	sudo -u hdfs "$@"
}

run-as-beeline() {
#	run-as-hdfs beeline -u jdbc:hive2://$(hostname):10000/default -n hdfs -e "$@"
        run-as-hdfs hive -e "$@"
}

create-core-hive-tables() {
	DATA_DIR=$1
	CREATE_TABLE="CREATE EXTERNAL TABLE IF NOT EXISTS "
	FORMAT=' ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t" '

	run-as-beeline "drop table if exists uuser;
                        drop table if exists streamsimple;
                        drop table if exists track;
                        drop table if exists wordhappiness;
                        drop table if exists lyrics;
                        $CREATE_TABLE uuser (id int, fname string, lname string, gender string, birthdate string, state string, registrationdate string) $FORMAT location \"$DATA_DIR/user\";
                        $CREATE_TABLE streamsimple (userid int, songid int, ts string) $FORMAT location \"$DATA_DIR/stream\";
                        $CREATE_TABLE track (id int, title string, artistname string) $FORMAT location \"$DATA_DIR/track\";
                        $CREATE_TABLE wordhappiness (word string, happiness float) $FORMAT location \"$DATA_DIR/wordhappiness\";
                        $CREATE_TABLE airport(id int, code string) $FORMAT location \"$DATA_DIR/airport\";
                        $CREATE_TABLE flight(airportFrom int, airportTo int, id int) $FORMAT location \"$DATA_DIR/flight\";
                        $CREATE_TABLE lyrics(song_id int, lyrics string) STORED AS AVRO location \"$DATA_DIR/lyrics\";
                       "
}


main() {
	create-core-hive-tables $1
}


[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
