#!/usr/bin/env python

# This scripts downloads Kafka parcel, distributes and actiates it and then installs kafka brokers on all datanodes in the cluster. It starts the service afterwards


from cm_api.api_client import ApiResource
from cm_api.endpoints.parcels import get_parcel
from time import sleep
import ConfigParser



#CONFIGURATION

CONFIG = ConfigParser.ConfigParser()
CONFIG.read('clouderaconfig.ini')
cm_host = CONFIG.get("CM", 'cm.host')
username = CONFIG.get("CM", 'admin.name')
password = CONFIG.get("CM", 'admin.password')
cluster_name = CONFIG.get("CM", 'cluster.name')
master_nodes = CONFIG.get("CDH", 'cluster.masternodes').split(',')
slave_nodes = CONFIG.get("CDH", 'cluster.slavenodes').split(',')
edge_nodes = CONFIG.get("CDH", 'cluster.edgenodes').split(',')


api = ApiResource(cm_host,version='13', username=username, password=password)

# Connect with the Cluster
CLUSTER = None
for cluster in api.get_all_clusters():
    #print c.name
    CLUSTER = cluster


#Download and activate Kafka parcel
PARCEL = None
PARCEL_PRODUCT = None
PARCEL_VERSION = None
for p in CLUSTER.get_all_parcels():
#    print p
#    print p.product
#    print p.version
    if p.product == "KAFKA":
        PARCEL = p
        PARCEL_PROCUCT = p.product
        PARCEL_VERSION = p.version

print PARCEL

print "Starting parcel download. This may take a while"
cmd = PARCEL.start_download()
if cmd.success != True:
    print "Parcel download failed!"
    exit(0)

while PARCEL.stage != "DOWNLOADED":
    sleep(5)
    PARCEL = get_parcel(api, PARCEL_PROCUCT, PARCEL_VERSION, cluster_name)

print "Parcel downloaded"

print "Starting parcel distribution. This might take a while"
cmd = PARCEL.start_distribution()
if cmd.success != True:
    print "Parcel distribution failed!"
    exit(0)

while PARCEL.stage != "DISTRIBUTED":
    sleep(5)
    PARCEL = get_parcel(api, PARCEL_PROCUCT, PARCEL_VERSION, cluster_name)

print "Parcel distributed"

print "Activating the parcel"
cmd = PARCEL.activate()
if cmd.success != True:
    print "PArcel Activation failed!"
    exit(0)

while PARCEL.stage != "ACTIVATED":
    PARCEL = get_parcel(api, PARCEL_PROCUCT, PARCEL_VERSION, cluster_name)

print "Parcel activated!"


kafka_service = CLUSTER.create_service('kafka', "KAFKA")

#NEEDS TO BE EXACTLY AS ON CLUSTER //to do find automatic  
zookeeper_name = "ZOOKEEPER-1"

kafka_service.update_config({'zookeeper_service': zookeeper_name})

#Create kafka brokers on datanodes

slave = 0
for s in slave_nodes:
    slave += 1
    kafka_service.create_role('kafkabroker'+str(slave), "KAFKA_BROKER", s)


kafka_service.start()
