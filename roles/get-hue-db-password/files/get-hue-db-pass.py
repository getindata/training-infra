#!/usr/bin/env python

from cm_api.endpoints.role_config_groups import get_all_role_config_groups
from cm_api.api_client import ApiResource
import ConfigParser

#CONFIGURATION
CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')

cm_host = CONFIG.get("CM", 'cm.host')
cluster = CONFIG.get("CM", 'cluster.name')
cm_port = 7180
cm_username = "admin"
cm_password = "admin"
service_name = CONFIG.get("CM", 'hue.servicename')

api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=7)

#Get cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    CLUSTER = cluster

print 'got cluster'

for service in CLUSTER.get_all_services():
    if service.name == service_name:
        print service.name
        for value in service.get_config(view='full'):
            if 'database_password' in value:
                hue_db_pass = str(value['database_password']).split(' ')[-1]

print hue_db_pass

hue_db_pass_file = open('hue-db-pass', 'w')
hue_db_pass_file.write(hue_db_pass)
hue_db_pass_file.close()
