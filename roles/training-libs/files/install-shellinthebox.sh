#!/bin/bash

install-shellinaboxd() {
	rpm -Uvh http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm
	yum repolist
	yum install --assumeyes openssl shellinabox
	service shellinaboxd start
}


main() {
	install-shellinaboxd
}


[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
