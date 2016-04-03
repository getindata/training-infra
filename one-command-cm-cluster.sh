#!/bin/bash

USERNAME=ec2-user
PRIVATE_KEY=oregon.pem

TERRAFORM_CONF_DIR=$1

#./one-command-cm-step.sh aws ${TERRAFORM_CONF_DIR}
#./one-command-cm-step.sh setup ${TERRAFORM_CONF_DIR}

# sleep 4m

#./one-command-cm-step.sh cm ${TERRAFORM_CONF_DIR}
./one-command-cm-step.sh training ${TERRAFORM_CONF_DIR}
