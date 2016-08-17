#!/usr/bin/env python


from cm_api.api_client import ApiResource
import ConfigParser


#CONFIGURATION

CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')
master_nodes = CONFIG.get("CDH", 'cluster.masternodes').split(',')
slave_nodes = CONFIG.get("CDH", 'cluster.slavenodes').split(',')
edge_nodes = CONFIG.get("CDH", 'cluster.edgenodes').split(',')


api = ApiResource(cm_host, username=username, password=password)

# Connect with the Cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster


#Adding Hbase Service
#to do - automatically find hdfs and zookeeper names.

#Add hbase service
hbase_service = CLUSTER.create_service('hbase', 'HBASE')

#Configure hbase to connect with hdfs and zookeeper services
hdfs_name = "hdfs"
zookeeper_name = "zookeeper"
hbase_service.update_config({'hdfs_service': hdfs_name,'zookeeper_service': zookeeper_name,})

#Create Hbase master on master node
hbase_service.create_role('masterserver', 'MASTER', master_nodes[0])

#Add thrift server
hbase_service.create_role("thriftserver", "HBASETHRIFTSERVER", master_nodes[0])

#Create Hbase slave on all slave nodes
slave = 0
for s in slave_nodes:
    slave += 1
    hbase_service.create_role('regionserver'+str(slave), 'REGIONSERVER', s)

#Add gateways
gateway = 0
for g in edge_nodes:
    gateway += 1
    hbase_service.create_role("gateway" + str(gateway), "GATEWAY", g)

#Create hbase directory on hdfs
hbase_service.create_hbase_root()
hbase_service.start()


