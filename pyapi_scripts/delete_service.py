#!/usr/bin/env python

# This wont do any cleanup. Possible problems may occur.

from cm_api.api_client import ApiResource
import ConfigParser

CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')

cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')

api = ApiResource(cm_host, username=username, password=password)

CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster

CLUSTER.delete_service('kafka')