#!/usr/bin/env python
#Spark2 additional configuration


from cm_api.api_client import ApiResource
from commands import set_configuration_service, set_configuration_roles, restart_deployconfig
import ConfigParser


#CONFIGURATION
CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')
cluster_name = CONFIG.get("CM", 'cluster.name')
service_name = CONFIG.get('CM', 'spark2.servicename')

configuration = {}

for entry in CONFIG.items("Spark2_config"):
    configuration[entry[0]] = entry[1]

print configuration

api = ApiResource(cm_host, username=username, password=password)

#Get cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster

set_configuration_service(CLUSTER, service_name, configuration)
set_configuration_roles(service_name, cluster_name, configuration, api)
restart_deployconfig(CLUSTER, service_name)
cluster.restart(restart_only_stale_services=True, redeploy_client_configuration=True).wait()
