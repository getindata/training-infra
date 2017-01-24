#!/usr/bin/env python

#cloudera manager pyapi scrip
#Restart Cluster Script


from cm_api.api_client import ApiResource
from commands import set_configuration_service, set_configuration_roles, restart_deployconfig
import ConfigParser


CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')

cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')
hue_service_name = CONFIG.get("Hue_config", 'hue_service_name')
edge = CONFIG.get("CDH", 'cluster.edgenodes') 

api = ApiResource(cm_host, version='13', username=username, password=password)

CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster


def stop_service(cluster_object, service_name):
    for service in cluster_object.get_all_services():
        if service.name == service_name:
            print "Stopping the %s service" % service_name
            service.stop().wait()
            #print "Starting the %s service" % service_name
            #service.start().wait()
            #print "Deploying client configuration for %s" % service_name
            #service.deploy_client_config().wait()
print edge

def set_configuration_service(cluster_obj, service_name):
    # This function needs a cluster object from cm_api, name of the service you want to configure as string, and configuration dictionary
    for service in cluster_obj.get_all_services():
        if service.name == hue_service_name:
            for role in service.get_all_roles():
                service.delete_role(role.name)

def add_role(cluster_obj, service_name, edge):
    for service in cluster_obj.get_all_services():
        if service.name == hue_service_name:
            service.create_role('HUE-Server1', 'HUE_SERVER', edge)

stop_service(CLUSTER,hue_service_name)
set_configuration_service(CLUSTER, hue_service_name)
add_role(CLUSTER, hue_service_name, edge)

