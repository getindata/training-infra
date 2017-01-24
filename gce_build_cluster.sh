#use terraform to request machines for cluster
./one-command-step.sh aws terraform-clusters/test-google-piotrek/

#setup for all hosts on google cloud
ansible-playbook playbook/bootstrap_gce.yml -i inventories/gce/ -u piotrektt --private-key=pbatgetindata
ansible-playbook playbook/devenv.yml -i inventories/gce -u piotrektt --private-key=pbatgetindata
ansible-playbook playbook/setup-user.yml -i inventories/gce -u piotrektt --private-key=pbatgetindata
ansible-playbook playbook/selinux-disable.yml -i inventories/gce -u piotrektt --private-key=pbatgetindata
echo "Waiting for machines reboot"
sleep 120

#get gce hosts internal-ips
./get_gce_ips_from_terraform.py -i terraform-clusters/test-google-piotrek

#install cm and install cluster
ansible-playbook playbook/cm.yml -i inventories/gce/ -l tag_master -u piotrektt --private-key=pbatgetindata


#install mysql on edge, configure hue to use external database
#python playbook/stop_service.py
#ansible-playbook playbook/mysql.yml -i inventories/gce -l tag_edge -u piotrektt --private-key=pbatgetindata
#python playbook/start_service.py

#install and confiugre kafka
# To setup kafka we need to add cluster information to clouderaconfig.ini  -  cm ip address //to do use get_gce_ips to put in cm ip to the configuration
# This playbook is executed locally! 
#ansible-playbook playbook/cm-api.yml 

#install and konfigure flink






#install elasticsearch 
#ansible-playbook playbook/elasticsearch.yml -i inventories/gce -l tag_slave -u piotrektt --private-key=pbatgetindata

#install kibana
#ansible-playbook playbook/kibana.yml -i inventories/gce -l tag_edge -u piotrektt --private-key=pbatgetindata

#install sbt
#ansible-playbook playbook/install-sbt.yml -i inventories/gce -l tag_edge -u piotrektt --private-key=pbatgetindata

