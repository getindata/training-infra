#!/usr/bin/env python 

import subprocess
import sys
import getopt
import fileinput
import re
 

def get_part(line, splitter, index):
    return line.split(splitter)[index]


def parse_terraform_show(path):
    host = []
    i = 0
    cmd = subprocess.Popen('terraform show %s' % (path), shell=True, stdout=subprocess.PIPE)
    for line in cmd.stdout:
        if 'private_dns' in line:
            host.append({})
            host[i]['private_dns'] = get_part(line, ' = ', 1).strip()

        if 'public_ip' in line:
            host[i]['public_ip'] = get_part(line, ' = ', 1).strip()
            i = i + 1

    return host


def write_hosts_file(host):
    filename = 'hosts_%s' % (host[0]['public_ip'])
    fo = open(filename, "wb")

    fo.write("[master]\n");
    fo.write("xbsd-master-1 ansible_ssh_host=%s\n" % (host[0]['public_ip']))
    fo.write("[slave]\n")
    for j in range(len(host) - 1):
        fo.write("xbsd-slave-%d ansible_ssh_host=%s\n" % (j+1, host[j+1]['public_ip']))

    fo.close()
    return filename


def link_filename(filename):
    subprocess.Popen('rm -rf hadoop_hosts', shell=True, stdout=subprocess.PIPE)
    subprocess.Popen('ln -s %s hadoop_hosts' % (filename), shell=True, stdout=subprocess.PIPE)


def write_hosts_list(host):
    command = "  command: /tmp/cdh-setup.py --cmhost %s" % (host[0]['private_dns'])
    command += " --nodes"
    for j in range(len(host)):
        command += " %s" % (host[j]['private_dns'])

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
