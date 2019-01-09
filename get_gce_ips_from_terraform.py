#!/usr/bin/env python 

import subprocess
import sys
import getopt
import fileinput
import re
 

def get_part(line, splitter, index):
    return line.split(splitter)[index]

def parse_terraform_show(path):
    host = {}
    cmd = subprocess.Popen('terraform show %s' % (path), shell=True, stdout=subprocess.PIPE)
    #cmd = subprocess.Popen('cat %s' % (path), shell=True, stdout=subprocess.PIPE)
    for line in cmd.stdout:
        if 'google_compute_instance.' in line:
            type = get_part(get_part(line, ':', 0), '.', 1).strip()
            if not type in host:
                host[type] = {}
                if not 'private_dns' in host[type]:
                    host[type]['private_dns'] = []
                if not 'public_ip' in host[type]:
                    host[type]['public_ip'] = []

        if 'id' in line and not 'instance_id' in line:
            host[type]['private_dns'].append(get_part(line, ' = ', 1).strip()+".c.getindata-training.internal")

        if 'network_interface.0.access_config.0.nat_ip' in line:
            host[type]['public_ip'].append(get_part(line, ' = ', 1).strip())

    #print host
    return host

def write_host_to_file(host, type, fo):
    fo.write("[%s]\n" % (type))
    if type in host:
        for i in range(len(host[type]['public_ip'])):
            fo.write("%s-%d ansible_ssh_host=%s\n" % (type, i+1, host[type]['public_ip'][i]))


def write_hosts_file(host, directory):
    filename = '%s/hosts' % (directory)
    fo = open(filename, "wb")

    write_host_to_file(host, 'edge', fo)
    write_host_to_file(host, 'master', fo) 
    write_host_to_file(host, 'slave', fo)

    fo.close()
    return filename


def write_master_ip_to_clouderaconfig(host):
    command = "cm.host=%s\n" % (host['master']['public_ip'][0])
    
    with open('playbook/clouderaconfig.ini', 'r') as file:
        data = file.readlines()
    data[1] = command
    
    with open('playbook/clouderaconfig.ini', 'w') as file:
        file.writelines(data)    

opts, args = getopt.getopt(sys.argv[1:],"i:")
for k, v in opts:
    if k == '-i':
        terraform_dir = v

path = '%s/terraform.tfstate' % terraform_dir
host = parse_terraform_show(path)

print host


if len(host) > 0:
    filename = write_hosts_file(host, terraform_dir)
write_master_ip_to_clouderaconfig(host)

