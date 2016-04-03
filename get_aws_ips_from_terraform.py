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
    for line in cmd.stdout:
        if 'aws_instance.' in line:
            type = get_part(line, '.', 1).strip()[:-1]
            if not type in host:
                host[type] = {}
                host[type]['private_dns'] = []
                host[type]['public_ip'] = []

        if 'private_dns' in line:
            host[type]['private_dns'].append(get_part(line, ' = ', 1).strip())

        if 'public_ip' in line:
            host[type]['public_ip'].append(get_part(line, ' = ', 1).strip())

    return host


def write_host_to_file(host, type, fo):
    print type, host[type]
    fo.write("[%s]\n" % (get_part(type, '-', 1)))
    for i in range(len(host[type]['public_ip'])):
        fo.write("xbsd-%s-%d ansible_ssh_host=%s\n" % (type, i, host[type]['public_ip'][i-1]))


def write_hosts_file(host):
    filename = 'hosts_%s' % (host['cdh-master']['public_ip'][0])
    fo = open(filename, "wb")

    write_host_to_file(host, 'cdh-edge', fo)
    write_host_to_file(host, 'cdh-master', fo) 
    write_host_to_file(host, 'cdh-slave', fo)

    fo.close()
    return filename


def link_filename(filename):
    subprocess.Popen('rm -rf hadoop_hosts', shell=True, stdout=subprocess.PIPE)
    subprocess.Popen('ln -s %s hadoop_hosts' % (filename), shell=True, stdout=subprocess.PIPE)


def write_hosts_list(host):
    command = "  command: /tmp/cdh-setup.py --cmhost %s" % (host['cdh-master']['private_dns'][0])
    command += " --nodes"
    all_nodes = []
    for type in ['cdh-master', 'cdh-slave']:
        all_nodes += host[type]['private_dns']

    for node in all_nodes:
        command += " %s" % node

    print command
    
    file = open('roles/cm/tasks/main.yml')
    lines = file.readlines()
    lines = lines[:-1]
    lines.append(command)
    file.close()

    fo = open('roles/cm/tasks/main.yml', "wb")
    fo.write(''.join(lines))
    fo.close()


path = 'terraform.tfstate'
opts, args = getopt.getopt(sys.argv[1:],"p:")
for k, v in opts:
    if k == '-p':
        path = v

host = parse_terraform_show(path)

if len(host) > 0:
    filename = write_hosts_file(host)
    link_filename(filename)
    write_hosts_list(host)
