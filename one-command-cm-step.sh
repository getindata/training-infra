#!/bin/bash

USERNAME=ec2-user
PRIVATE_KEY=oregon.pem

STEP=$1
TERRAFORM_CONF_DIR=$2

TERRAFORM_PLAN=${TERRAFORM_CONF_DIR}/config.tf.plan
TERRAFORM_STATE=${TERRAFORM_CONF_DIR}/terraform.tfstate

display_usage() { 
    echo -e "\nUsage:\n$0 <step> <terraform-config-path> \n"
} 

if [  $# -le 1 ]; then 
    display_usage
    exit 1
fi 

if [[ ! -f ${PRIVATE_KEY} ]] ; then
    echo 'File "${PRIVATE_KEY}" is not there, aborting.'
    exit
fi

if [ "${STEP}" == "aws" ] ; then
    terraform plan -out=${TERRAFORM_PLAN} ${TERRAFORM_CONF_DIR}
    terraform apply -state=${TERRAFORM_STATE} ${TERRAFORM_CONF_DIR}
fi

./get_aws_ips_from_terraform.py -p ${TERRAFORM_STATE}

if [ "${STEP}" == "setup" ] ; then
    ansible-playbook playbook/bootstrap.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/devenv.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/setup-user.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/selinux-disable.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

if [ "${STEP}" == "cm" ] ; then
    ansible-playbook playbook/cm.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/cdh.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

if [ "${STEP}" == "training" ] ; then
    ansible-playbook playbook/training-setup.yml -i hadoop_hosts -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi
