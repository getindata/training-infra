#!/usr/bin/env python

from cm_api.endpoints.role_config_groups import get_all_role_config_groups


#Look for configuration values for service and change them

def set_configuration_service(cluster_obj, service_name, configuration_file):
    # This function needs a cluster object from cm_api, name of the service you want to configure as string, and configuration dictionary
    for service in cluster_obj.get_all_services():
        if service.name == service_name:
            for value in service.get_config(view='full'):
                for key in value:
                    if key in configuration_file:
                        service.update_config({key:configuration_file[key]})

# Look for configuration values for roles in a service and change them
def set_configuration_roles(service_name, cluster_name, configuration_file, api_object):
    for role in get_all_role_config_groups(api_object, service_name, cluster_name):
        for value in role.get_config(view='full'):
            if value in configuration_file:
                role.update_config({value:configuration_file[value]})

#Restart service and deploy client configuration if needed.
def restart_deployconfig(cluster_object, service_name):
    for service in cluster_object.get_all_services():
        if service.name == service_name:
            print "Stopping the %s service" % service_name
            service.stop().wait()
            print "Starting the %s service" % service_name
            service.start().wait()
            print "Deploying client configuration for %s" % service_name
            service.deploy_client_config().wait()

#This will list all available configuration for all service/roles
#for role in get_all_role_config_groups(api, 'hdfs', 'Cluster Test'):
#    for value in role.get_config(view='full'):
#        print value