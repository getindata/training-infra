#!/bin/bash


INSTALL_DIR="/opt/cloudera/parcels/CDH/lib/"
USER=$1
PASSWORD_SUFFIX=$2
HUE_DB_PASS=$3

export HUE_CONF_DIR="/var/run/cloudera-scm-agent/process/`ls -alrt /var/run/cloudera-scm-agent/process | grep HUE | tail -1 | awk '{print $9}'`"
export HUE_IGNORE_PASSWORD_SCRIPT_ERRORS=1
export HUE_DATABASE_PASSWORD=$HUE_DB_PASS

#/opt/cloudera/parcels/CDH/lib/hue/build/env/bin/hue shell <<EOF
${INSTALL_DIR}/hue/build/env/bin/hue shell <<EOF
from django.contrib.auth.models import User
from django.contrib.auth.models import Group
user = User.objects.create(username='${USER}')
user.set_password('${USER}${PASSWORD_SUFFIX}')
user.is_active = True
user.is_superuser = True
group_obj = Group.objects.get(name="default")
user.groups.add(group_obj)
user.save()
EOF
