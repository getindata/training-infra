#!/usr/bin/env python

# based on https://raw.githubusercontent.com/cloudera/cm_api/master/python/examples/cluster_set_up.py

from cm_api.api_client import ApiResource
from cm_api.api_client import ApiException
from cm_api.endpoints.clusters import ApiCluster
from cm_api.endpoints.clusters import create_cluster
from cm_api.endpoints.parcels import ApiParcel
from cm_api.endpoints.parcels import get_parcel
from cm_api.endpoints.cms import ClouderaManager
from cm_api.endpoints.services import ApiService, ApiServiceSetupInfo
from cm_api.endpoints.services import create_service
from cm_api.endpoints.role_config_groups import ApiRoleConfigGroup
from cm_api.endpoints.roles import ApiRole
from time import sleep

import re
import argparse

cluster_name = "Training Cluster"
cm_port = 7180
cm_username = "admin"
cm_password = "admin"
cds_parcel_name = "SPARK2"
cds_parcel_repo = 'http://archive.cloudera.com/spark2/parcels/2.3.0.cloudera4/'
cds_parcel_version = '2.3.0.cloudera4-1.cdh5.13.3.p0.611179'
cds_service_type = "SPARK2_ON_YARN"
cds_service_name = "SPARK2_ON_YARN-1"

def wait_for_parcel(cmd, api, parcel, cluster_name, stage):
  if cmd.success != True:
    print "Parcel stage transition to %s failed: " % stage
    exit(7)
  while parcel.stage != stage:
    sleep(5)
    parcel = get_parcel(api, parcel.product, parcel.version, cluster_name)
  return parcel

def is_cluster_installed(api):
  clusters = api.get_all_clusters()
  return len(clusters.objects) > 0

def install_cds(cm_host, host_list):
  print "Installing CDS for Spark2"

  api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=7)
  cm = ClouderaManager(api)
  config = cm.get_config(view='full')

  # Add parcel repository
  repolist = config['REMOTE_PARCEL_REPO_URLS']
  value = repolist.value or repolist.default
  value += ',' + cds_parcel_repo
  cm.update_config({'REMOTE_PARCEL_REPO_URLS': value})
  sleep(10)

  # Install CDS parcel
  cluster = api.get_cluster(cluster_name)
  parcel = cluster.get_parcel(cds_parcel_name, cds_parcel_version)

  print "Downloading CDS parcel. This might take a while."
  if parcel.stage == "AVAILABLE_REMOTELY":
    parcel = wait_for_parcel(parcel.start_download(), api, parcel, cluster_name, 'DOWNLOADED')

  print "Distributing CDS parcel. This might take a while."
  if parcel.stage == "DOWNLOADED":
    parcel = wait_for_parcel(parcel.start_distribution(), api, parcel, cluster_name, 'DISTRIBUTED')

  print "Activating CDS parcel. This might take a while."
  if parcel.stage == "DISTRIBUTED":
    parcel = wait_for_parcel(parcel.activate(), api, parcel, cluster_name, 'ACTIVATED')

  service = cluster.create_service(cds_service_name, cds_service_type)

  slaves = [ host for host in host_list if 'slave' in host]
  edges = [ host for host in host_list if 'edge' in host]

  service.create_role('SPARK2_YARN_HISTORY_SERVER-1', 'SPARK2_YARN_HISTORY_SERVER', cm_host)
  service.create_role('SPARK2_ON_YARN-GW_MASTER1', 'GATEWAY', cm_host)
  for (i, edge) in enumerate(edges):
    service.create_role('SPARK2_ON_YARN-GW_EDGE%s' % i, 'GATEWAY', edge)
  for (i, slave) in enumerate(slaves):
    service.create_role('SPARK2_ON_YARN-GW_SLAVE%s' % i, 'GATEWAY', slave)

  cluster.auto_configure()
  cluster.deploy_client_config().wait()

  # Restart Cloudera Management Service and cluster
  cm_service = cm.get_service()
  cm_service.restart().wait()
  cluster.restart().wait()

  # Due to (presumably) CM bug, auto_configure() after Kafka installation creates additional
  # role config group for HDFS gateway, which breaks further use of auto_configure().
  # Below we remove it if it exists.
  try:
    hdfs_service = cluster.get_service("HDFS-1")
    hdfs_service.delete_role_config_group("HDFS-1-GATEWAY-1")
  except cm_api.api_client.ApiException:
    print("Not removing HDFS Gateway role config group as it doesn't exist")
  else:
    print("Removed additional HDFS Gateway role config group")

  print "CDS is now installed."

def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('-c', '--cmhost', nargs=1, metavar='hostname', help='Specify hostname of Cloudera Manager node', required=True)
  parser.add_argument('-n', '--nodes', nargs='+', metavar='hostname', help='Specify all cluster nodes', required=True)
  args = parser.parse_args()

  install_cds(args.cmhost[0], args.nodes)

if __name__ == "__main__":
  main()
