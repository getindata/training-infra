#!/bin/bash

USERNAME=ec2-user
TERRAFORM_CONF_DIR=$1

#./one-command-step.sh aws ${TERRAFORM_CONF_DIR}

./one-command-step.sh setup ${TERRAFORM_CONF_DIR}

./one-command-step.sh cm ${TERRAFORM_CONF_DIR}

./one-command-step.sh training ${TERRAFORM_CONF_DIR}

./one-command-step.sh mysql ${TERRAFORM_CONF_DIR}
./one-command-step.sh confluent ${TERRAFORM_CONF_DIR}
