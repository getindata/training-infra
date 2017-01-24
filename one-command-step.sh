#!/bin/bash

set -x

USERNAME=piotrektt

STEP=$1
TERRAFORM_CONF_DIR=$2

PRIVATE_KEY=${TERRAFORM_CONF_DIR}pbatgetindata
TERRAFORM_PLAN=config.tf.plan
TERRAFORM_STATE=terraform.tfstate
HOSTS_FILE=${TERRAFORM_CONF_DIR}hosts


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
    cd ${TERRAFORM_CONF_DIR}
    terraform plan -out=${TERRAFORM_PLAN} 
    terraform apply -state=${TERRAFORM_STATE} 
fi

# TODO: write the output file '${HOSTS_FILE}' to the directory where terraform config is
#./get_aws_ips_from_terraform.py -i ${TERRAFORM_CONF_DIR}

if [ "${STEP}" == "mysql" ] ; then
    ansible-playbook playbook/mysql.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

if [ "${STEP}" == "setup" ] ; then
    ansible-playbook playbook/bootstrap.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/devenv.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/setup-user.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/selinux-disable.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    echo "Sleeping after reboot"
    sleep 120
fi

if [ "${STEP}" == "cm" ] ; then
    ansible-playbook playbook/cm.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/cdh.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/ntpd-enable.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

if [ "${STEP}" == "training" ] ; then
    ansible-playbook playbook/training-setup.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi

if [ "${STEP}" == "confluent" ] ; then
    ansible-playbook playbook/confluent.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi
