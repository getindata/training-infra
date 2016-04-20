#!/bin/bash

INSTALL_DIR="/usr/local/"

USER=$1

${INSTALL_DIR}/hue/build/env/bin/hue shell <<EOF
from django.contrib.auth.models import User
user = User.objects.get(username='${USER}')
user.set_password('${USER}')
user.is_superuser = True
user.save()
EOF
