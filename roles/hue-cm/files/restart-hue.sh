#!/bin/bash

: ${INSTALL_DIR:=/usr/local/}

restart-hue() {
  ${INSTALL_DIR}/hue/build/env/bin/supervisor -d
}

main(){
  restart-hue
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
