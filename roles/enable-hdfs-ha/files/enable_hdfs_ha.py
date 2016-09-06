from cm_api.endpoints.services import ApiService
from cm_api.api_client import ApiResource
import ConfigParser


#CONFIGURATION
CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')

api = ApiResource(cm_host, username=username, password=password)

#Get cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster


for service in CLUSTER.get_all_services():
    if service.name == 'hdfs':
        service_obj = service

namenode_name = service_obj.get_roles_by_type('NAMENODE')
for n in namenode_name:
    namenode_name = n.name

#from documentation:
service_obj.enable_nn_ha(namenode_name, 'cdh-master-2.gid', 'nameservice1', [{'jnHostId':'cdh-master-1.gid', 'jnEditsDir':'/dfs/jn'}, {'jnHostId':'cdh-master-2.gid', 'jnEditsDir':'/dfs/jn'}, {'jnHostId':'cdh-edge-1.gid', 'jnEditsDir':'/dfs/jn'}])