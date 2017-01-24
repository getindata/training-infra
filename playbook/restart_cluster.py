#!/usr/bin/env python
#Restart Cluster Script


from cm_api.api_client import ApiResource
import ConfigParser


CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')

cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')

api = ApiResource(cm_host,version='13', username=username, password=password)

cdh4 = None
for c in api.get_all_clusters():
    #print c.name
    cdh4 = c

print "Restarting %s" % cdh4.name
cmd = cdh4.restart().wait()
print "Success: %s" % (cmd.success)


