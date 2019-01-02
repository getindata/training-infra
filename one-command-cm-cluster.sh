#!/bin/bash

USERNAME=admin
TERRAFORM_CONF_DIR=$1

set -e -x

./one-command-step.sh gce ${USERNAME} ${TERRAFORM_CONF_DIR}
./one-command-step.sh setup ${USERNAME} ${TERRAFORM_CONF_DIR}
./one-command-step.sh mysql ${USERNAME} ${TERRAFORM_CONF_DIR}
./one-command-step.sh cm ${USERNAME} ${TERRAFORM_CONF_DIR}
#./one-command-step.sh training ${USERNAME} ${TERRAFORM_CONF_DIR}
#./one-command-step.sh confluent ${USERNAME} ${TERRAFORM_CONF_DIR}
