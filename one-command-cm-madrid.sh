#!/bin/bash

ansible-playbook playbook/bootstrap.yml -i hadoop_hosts -u ec2-user --private-key ~/Luis.pem


#[edge]
#xbsd-cdh-edge-0 ansible_ssh_host=52.19.183.78
#[master]
#xbsd-cdh-master-0 ansible_ssh_host=ec2-54-171-248-134.eu-west-1.compute.amazonaws.com
#[slave]
#xbsd-cdh-slave-0 ansible_ssh_host=ec2-54-229-118-81.eu-west-1.compute.amazonaws.com
#xbsd-cdh-slave-1 ansible_ssh_host=ec2-54-171-177-143.eu-west-1.compute.amazonaws.com
#xbsd-cdh-slave-2 ansible_ssh_host=ec2-54-171-238-94.eu-west-1.compute.amazonaws.com
#xbsd-cdh-slave-3 ansible_ssh_host=ec2-54-229-187-151.eu-west-1.compute.amazonaws.com
#xbsd-cdh-slave-4 ansible_ssh_host=ec2-54-171-214-64.eu-west-1.compute.amazonaws.com
