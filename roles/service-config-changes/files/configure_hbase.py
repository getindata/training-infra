#!/usr/bin/env python
#HBase additional configuration


from cm_api.api_client import ApiResource
from commands import set_configuration_service, set_configuration_roles, restart_deployconfig
import ConfigParser


#CONFIGURATION
CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')
service_name = CONFIG.get('CM', 'hbase.servicename')
cluster_name = CONFIG.get('CM', 'cluster.name')


configuration = {}

for entry in CONFIG.items("Hbase_config"):
    configuration[entry[0]] = entry[1]

print configuration

api = ApiResource(cm_host,version='13', username=username, password=password)

#Get cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster


set_configuration_service(CLUSTER, service_name, configuration)
set_configuration_roles(service_name, cluster_name, configuration, api)
restart_deployconfig(CLUSTER, service_name)


