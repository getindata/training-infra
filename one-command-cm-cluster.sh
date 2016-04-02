#!/bin/bash

USERNAME=ec2-user
STEP=$1
TERRAFORM_CONF_DIR=$2
PRIVATE_KEY=$3

TERRAFORM_PLAN=${TERRAFORM_CONF_DIR}/config.tf.plan
TERRAFORM_STATE=${TERRAFORM_CONF_DIR}/terraform.tfstate

if [[ ! -f oregon.pem ]] ; then
    echo 'File "oregon.pem" is not there, aborting.'
    exit
fi

terraform plan -out=${TERRAFORM_PLAN} ${TERRAFORM_CONF_DIR}
terraform apply -state=${TERRAFORM_STATE} ${TERRAFORM_CONF_DIR}
./get_aws_ips_from_terraform.py -p ${TERRAFORM_STATE}

if [ "${STEP}" == "setup" ] ; then
    ansible-playbook playbook/bootstrap.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/devenv.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/setup-user.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/selinux-disable.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

# sleep 4m

if [ "${STEP}" == "cm" ] ; then
    ansible-playbook playbook/cm.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/cdh.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi
