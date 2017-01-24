#!/usr/bin/env python

from cm_api.endpoints.role_config_groups import get_all_role_config_groups
from cm_api.api_client import ApiResource
import ConfigParser

#CONFIGURATION
CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')

#this need to be exactly as on cluster /todo - automatic find 
service_name = 'HUE-1'



api = ApiResource(cm_host, version='13',username=username, password=password)


#Get cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster
    
hue_db_pass = ''

for service in CLUSTER.get_all_services():
    if service.name == service_name:
        for value in service.get_config(view='full'):
            if 'database_password' in value:
                hue_db_pass = str(value['database_password']).split(' ')[-1]

hue_db_pass_file = open('hue-db-pass', 'w')
hue_db_pass_file.write(hue_db_pass)
hue_db_pass_file.close()

