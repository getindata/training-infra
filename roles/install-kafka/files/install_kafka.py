#!/usr/bin/env python

# This scripts downloads Kafka parcel, distributes and actiates it and then installs kafka brokers on all datanodes in the cluster. It starts the service afterwards


from cm_api.api_client import ApiResource
from cm_api.endpoints.parcels import get_parcel
from time import sleep
import ConfigParser

def wait_for_parcel(cmd, api, parcel, cluster_name, stage):
  if cmd.success != True:
    print "Parcel stage transition to %s failed: " % stage
    exit(7)
  while parcel.stage != stage:
    sleep(5)
    parcel = get_parcel(api, parcel.product, parcel.version, cluster_name)
  return parcel


#CONFIGURATION

config = ConfigParser.ConfigParser()
config.read('clouderaconfig.ini')
cm_host = config.get("CM", 'cm.host')
username = config.get("CM", 'admin.name')
password = config.get("CM", 'admin.password')
cluster_name = config.get("CM", 'cluster.name')
master_nodes = config.get("CDH", 'cluster.masternodes').split(',')
slave_nodes = config.get("CDH", 'cluster.slavenodes').split(',')
edge_nodes = config.get("CDH", 'cluster.edgenodes').split(',')


api = ApiResource(cm_host, username=username, password=password)

# Connect with the Cluster
cluster = None
for cluster in api.get_all_clusters():
    #print c.name
    cluster = cluster


#Download and activate Kafka parcel
parcel = None
parcel_product = None
parcel_version = None
for p in cluster.get_all_parcels():
    if p.product == "KAFKA":
        parcel = p
        parcel_product = p.product
        parcel_version = p.version

print parcel

print "Downloading Kafka parcel. This might take a while."
if parcel.stage == "AVAILABLE_REMOTELY":
  parcel = wait_for_parcel(parcel.start_download(), api, parcel, cluster_name, 'DOWNLOADED')

print "Distributing Kafka parcel. This might take a while."
if parcel.stage == "DOWNLOADED":
  parcel = wait_for_parcel(parcel.start_distribution(), api, parcel, cluster_name, 'DISTRIBUTED')

print "Activating Kafka parcel. This might take a while."
if parcel.stage == "DISTRIBUTED":
  parcel = wait_for_parcel(parcel.activate(), api, parcel, cluster_name, 'ACTIVATED')

kafka_service = cluster.create_service('KAFKA-1', "KAFKA")

for (i, slave) in enumerate(slave_nodes):
  kafka_service.create_role('KAFKA-BROKER_%i' % i, 'KAFKA_BROKER', slave)
for (i, edge) in enumerate(edge_nodes):
  kafka_service.create_role('KAFKA-GW_EDGE%s' % i, 'GATEWAY', edge)

cluster.auto_configure()
cluster.restart(restart_only_stale_services=True, redeploy_client_configuration=True).wait()
kafka_service.start().wait()
