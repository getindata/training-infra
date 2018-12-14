#!/bin/bash

: ${INSTALL_DIR:=/usr/local/}

sync-hue() {
  ${INSTALL_DIR}/hue/build/env/bin/hue syncdb --noinput
  ${INSTALL_DIR}/hue/build/env/bin/hue migrate
}

main(){
  sync-hue
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"
