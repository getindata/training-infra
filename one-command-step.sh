#!/bin/bash

set -x -e

STEP=$1
USERNAME=$2
CLUSTER_DIR=$3
PRIVATE_KEY=${CLUSTER_DIR}/id_rsa_training
HOSTS_FILE=${CLUSTER_DIR}/hosts

display_usage() { 
    echo -e "\nUsage:\n$0 <step> <username> <cluster_dir> \n"
} 

if [  $# -le 2 ]; then 
    display_usage
    exit 1
fi 

if [[ ! -f ${PRIVATE_KEY} ]] ; then
    echo 'File "${PRIVATE_KEY}" is not there, aborting.'
    exit
fi

if [ "${STEP}" == "gce" ] ; then
    ( cd ${CLUSTER_DIR}; terraform plan; terraform apply )
    ./get_gce_ips_from_terraform.py -i ${CLUSTER_DIR}
fi


if [ "${STEP}" == "mysql" ] ; then
    ansible-playbook playbook/mysql.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
fi


if [ "${STEP}" == "setup" ] ; then
    ansible-playbook playbook/bootstrap.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/devenv.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/setup-user.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
    ansible-playbook playbook/selinux-disable.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
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
