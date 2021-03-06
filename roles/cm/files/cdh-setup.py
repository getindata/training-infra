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
cdh_version = "CDH5"
cdh_version_number = "5.16.1"
hive_metastore_name = "hive"
hive_metastore_user = "hive"
hive_metastore_password = "hive_password:)"
hive_metastore_database_type = "postgresql"
hive_metastore_database_port = 7432
hue_db_name = "hue"
hue_db_user = "hue"
hue_db_password = "hue"
hue_db_port = "3306"
hue_db_type = "mysql"
cm_port = 7180
cm_username = "admin"
cm_password = "admin"
cm_service_name = "mgmt"
host_username = "cdh"
host_password = "Cloudera"
anaconda_repo = 'https://repo.anaconda.com/pkgs/misc/parcels/archive'
anaconda_parcel_version = '5.0.1'
service_types_and_names = {
   "ZOOKEEPER" : "ZOOKEEPER-1",
   "HDFS" : "HDFS-1",
   "YARN" : "YARN-1",
#   "MAPREDUCE" : "MAPREDUCE-1",
   "HBASE" : "HBASE-1",
   "OOZIE" : "OOZIE-1",
   "HIVE" : "HIVE-1",
   "HUE" : "HUE-1",
#  "KAFKA" : "KAFKA-1",
   "IMPALA" : "IMPALA-1",
   "SPARK_ON_YARN" : "SPARK_ON_YARN-1",
  # "SOLR" : "SOLR-1",
   "SQOOP" : "SQOOP-1",
   "SQOOP_CLIENT" : "SQOOP_CLIENT"
}

def get_cdh_parcel(cluster):
  parcels_list = []
  print "Available parcels:"
  for p in cluster.get_all_parcels():
      print '\t' + p.product + ' ' + p.version
      #if p.version.startswith(cdh_version_number) and p.product == "CDH":
      if "cdh5" in p.version:
        parcels_list.append(p)
  if len(parcels_list) == 0:
      print "No " + cdh_version + " parcel found!"
      exit(4)
  cdh_parcel = parcels_list[0]
  for p in parcels_list:
      if p.version > cdh_parcel.version:
        cdh_parcel = p
  return cdh_parcel

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

def set_up_cluster(cm_host, host_list):
  print "Setting up CDH cluster..."

  api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=7)
  cm = ClouderaManager(api)

  print "Creating mgmg service."
  try:
    service_setup = ApiServiceSetupInfo(name=cm_service_name, type="MGMT")
    cm.create_mgmt_service(service_setup)
  except ApiException as exc:
    if exc.code != 400:
      print "create MGMT service failed: " + exc
      exit(1)

  print "Installing hosts. This might take a while."
  cmd = cm.host_install(host_username, host_list, password=host_password).wait()
  if cmd.success != True:
    print "cm_host_install failed: " + cmd.resultMessage
    exit(2)

  print "Auto-assign roles and auto-configure the CM service"
  if not is_cluster_installed(api):
    cm.auto_assign_roles()
    cm.auto_configure()

  print "Creating cluster."
  if not is_cluster_installed(api):
    cluster = create_cluster(api, cluster_name, cdh_version)
    cluster.add_hosts(host_list)
  cluster = api.get_cluster(cluster_name)

  cdh_parcel = get_cdh_parcel(cluster)

  print "Downloading CDH parcel. This might take a while."
  if cdh_parcel.stage == "AVAILABLE_REMOTELY":
    cdh_parcel = wait_for_parcel(cdh_parcel.start_download(), api, cdh_parcel, cluster_name, 'DOWNLOADED')

  print "Distributing CDH parcel. This might take a while."
  if cdh_parcel.stage == "DOWNLOADED":
    cdh_parcel = wait_for_parcel(cdh_parcel.start_distribution(), api, cdh_parcel, cluster_name, 'DISTRIBUTED')

  print "Activating CDH parcel. This might take a while."
  if cdh_parcel.stage == "DISTRIBUTED":
    cdh_parcel = wait_for_parcel(cdh_parcel.activate(), api, cdh_parcel, cluster_name, 'ACTIVATED')

#  if cdh_parcel.stage != "ACTIVATED":
#    print "CDH parcel activation failed. Parcel in stage: " + cdh_parcel.stage
#    exit(14)

  print "Inspecting hosts. This might take a few minutes."
  cmd = cm.inspect_hosts()
  while cmd.success == None:
      cmd = cmd.fetch()
  if cmd.success != True:
      print "Host inpsection failed!"
      exit(8)
  print "Hosts successfully inspected: \n" + cmd.resultMessage

  print "Creating specified services."
  for s in service_types_and_names.keys():
    try:
      cluster.get_service(service_types_and_names[s])
    except:
      print "Creating service: " + service_types_and_names[s]
      service = cluster.create_service(service_types_and_names[s], s)

  slaves = [ host for host in host_list if 'slave' in host]
  edges = [ host for host in host_list if 'edge' in host]

  #assign master roles to master node
  for service in cluster.get_all_services():
    if service.name == 'HDFS-1':
      service.create_role('NAMENODE-1', 'NAMENODE', cm_host)
      service.create_role('SECONDARYNAMENODE', 'SECONDARYNAMENODE', cm_host)
      service.create_role('BALANCER-1', 'BALANCER', cm_host)
      service.create_role('HTTPFS-1', 'HTTPFS', cm_host)
      service.create_role('HDFS-GW_MASTER1', 'GATEWAY', cm_host)
      for (i, edge) in enumerate(edges):
        service.create_role('HDFS-GW_EDGE%s' % i, 'GATEWAY', edge)
      for (i, slave) in enumerate(slaves):
        service.create_role('DATANODE-%s' % i, 'DATANODE', slave)

    if service.name == 'ZOOKEEPER-1':
      service.create_role('ZOOKEEPERSERVER-1', 'SERVER', cm_host)

    if service.name == 'HBASE-1':
      service.create_role('MASTER-1', 'MASTER', cm_host)
      service.create_role('HBASETHRIFTSERVER-1', 'HBASETHRIFTSERVER', cm_host)
      for (i, slave) in enumerate(slaves):
        service.create_role('HBASE-RS-%s' % i, 'REGIONSERVER', slave)

    if service.name == 'HUE-1':
      service.create_role('HUE-MASTER1', 'HUE_SERVER', cm_host)
      service.create_role('HUE-LB_MASTER1', 'HUE_LOAD_BALANCER', cm_host)
      for (i, edge) in enumerate(edges):
        service.create_role('HUE-EDGE%s' % i, 'HUE_SERVER', edge)

    if service.name == 'HIVE-1':
      service.create_role('HIVEMETASTORE-1', 'HIVEMETASTORE', cm_host)
      service.create_role('HIVESERVER-1', 'HIVESERVER2', cm_host)
      service.create_role('HIVE-GW_MASTER1', 'GATEWAY', cm_host)
      for (i, edge) in enumerate(edges):
        service.create_role('HIVE-GW_EDGE%s' % i, 'GATEWAY', edge)
      for (i, slave) in enumerate(slaves):
        service.create_role('HIVE-GW_SLAVE%s' % i, 'GATEWAY', slave)

    if service.name == 'IMPALA-1':
      service.create_role('STATESTORE-1', 'STATESTORE', cm_host)
      service.create_role('CATALOGSERVER-1', 'CATALOGSERVER', cm_host)
      for (i, slave) in enumerate(slaves):
        service.create_role('IMPALAD-%s' % i, 'IMPALAD', slave)

    if service.name == 'OOZIE-1':
      service.create_role('OOZIE_SERVER-1', 'OOZIE_SERVER', cm_host)

    if service.name == 'SPARK_ON_YARN-1':
      service.create_role('SPARK_YARN_HISTORY_SERVER-1', 'SPARK_YARN_HISTORY_SERVER', cm_host)
      service.create_role('SPARK_ON_YARN-GW_MASTER%s' % i, 'GATEWAY', cm_host)
      for (i, edge) in enumerate(edges):
        service.create_role('SPARK_ON_YARN-GW_EDGE%s' % i, 'GATEWAY', edge)
      for (i, slave) in enumerate(slaves):
        service.create_role('SPARK_ON_YARN-GW_SLAVE%s' % i, 'GATEWAY', slave)

    if service.name == 'SQOOP-1':
      service.create_role('SQOOP_SERVER-1', 'SQOOP_SERVER', cm_host)

    if service.name == 'YARN-1':
      service.create_role('RESOURCEMANAGER-1', 'RESOURCEMANAGER', cm_host)
      service.create_role('JOBHISTORY-1', 'JOBHISTORY', cm_host)
      for (i, slave) in enumerate(slaves):
        service.create_role('NODEMANAGER-%s' % i, 'NODEMANAGER', slave)

  #print "Auto assigning roles."
  #cluster.auto_assign_roles()
  cluster.auto_configure()

  print "Updating Hive config."
  hive_metastore_host = cm_host # let's assume that
  hive = cluster.get_service(service_types_and_names["HIVE"])
  hive_config = { "hive_metastore_database_host" : hive_metastore_host, \
                  "hive_metastore_database_name" : hive_metastore_name, \
                  "hive_metastore_database_user" : hive_metastore_user, \
                  "hive_metastore_database_password" : hive_metastore_password, \
                  "hive_metastore_database_port" : hive_metastore_database_port, \
                  "hive_metastore_database_type" : hive_metastore_database_type }
  hive.update_config(hive_config)

  print "Updating Hue config."
  hue_db_host = cm_host # let's assume that
  hue = cluster.get_service(service_types_and_names["HUE"])
  hue_config = {  "database_host" : hue_db_host, \
                  "database_name" : hue_db_name, \
                  "database_user" : hue_db_user, \
                  "database_password" : hue_db_password, \
                  "database_port" : hue_db_port, \
                  "database_type" : hue_db_type }
  hue.update_config(hue_config)

  # Set Java version to OpenJDK
  cm.update_all_hosts_config({'java_home': '/usr/lib/jvm/java-openjdk'})

  print "Starting management service."
  cm_service = cm.get_service()
  cm_service.start().wait()

  print "Excuting first run command. This might take a while."
  cmd = cluster.first_run().wait()
  if cmd.success != True:
      print "The first run command failed: " + cmd.resultMessage
      exit(11)

  print "First run successfully executed. Your cluster has been set up!"

  config = cm.get_config(view='full')
  repolist = config['REMOTE_PARCEL_REPO_URLS']
  value = repolist.value or repolist.default
  value += ',' + anaconda_repo
  cm.update_config({'REMOTE_PARCEL_REPO_URLS': value})
  sleep(10)

  cluster = api.get_cluster(cluster_name)
  parcel = cluster.get_parcel('Anaconda', anaconda_parcel_version)

  print "Downloading Anaconda parcel. This might take a while."
  if parcel.stage == "AVAILABLE_REMOTELY":
    parcel = wait_for_parcel(parcel.start_download(), api, parcel, cluster_name, 'DOWNLOADED')

  print "Distributing Anaconda parcel. This might take a while."
  if parcel.stage == "DOWNLOADED":
    parcel = wait_for_parcel(parcel.start_distribution(), api, parcel, cluster_name, 'DISTRIBUTED')

  print "Activating Anaconda parcel. This might take a while."
  if parcel.stage == "DISTRIBUTED":
    parcel = wait_for_parcel(parcel.activate(), api, parcel, cluster_name, 'ACTIVATED')

  print "Anaconda is now installed."


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('-c', '--cmhost', nargs=1, metavar='hostname', help='specify hostname of cloudera manager', required=True)
  parser.add_argument('-n', '--nodes', nargs='+', metavar='hostname', help='specify all cluster nodes', required=True)
  args = parser.parse_args()

  set_up_cluster(args.cmhost[0], args.nodes)

if __name__ == "__main__":
  main()
