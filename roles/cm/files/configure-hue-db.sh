#!/bin/bash

configure-hue-db() {
  mysqladmin -u root password root

  mysql -p'root' -e "create database if not exists hue"

  mysql -p'root' -e "CREATE USER IF NOT EXISTS 'hue'@'%' IDENTIFIED BY 'hue'"
  mysql -p'root' -e "grant all on hue.* to 'hue'@'localhost' identified by 'hue';"
  mysql -p'root' -e "grant all on hue.* to 'hue'@'%' identified by 'hue';"
  mysql -p'root' -e "grant all on hue.* to 'hue'@'$(hostname)' identified by 'hue';"

  mysql -p'root' -e "FLUSH PRIVILEGES;"
}

main(){
  configure-hue-db
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
