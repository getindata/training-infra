###CORE INSTALLATION

#Variables 
USERNAME=
PRIVATEKEY=
MASTER_TAG=
EDGE_TAG=
SLAVE_TAG= 

#use terraform to request machines for cluster
#./one-command-step.sh aws libs/terraform/gce-tutorial

#Initial setup for all hosts on google cloud
#syntax e.g ansible-playbook playbook.yml -i inventory_dir -l(limit/no limit) tag_{tagname} -u username --private-key=key_file

#ansible-playbook playbook/bootstrap_gce.yml -i libs/inventories/gce/ -u $USERNAME --private-key=$PRIVATEKEY
#ansible-playbook playbook/devenv.yml -i libs/inventories/gce -u $USERNAME --private-key=$PRIVATEKEY
#ansible-playbook playbook/setup-user.yml -i libs/inventories/gce -u $USERNAME --private-key=$PRIVATEKEY
#ansible-playbook playbook/selinux-disable.yml -i libs/inventories/gce -u $USERNAME --private-key=$PRIVATEKEY
#echo "Waiting for machines reboot"
#sleep 120

#get gce hosts internal-ips
#./get_gce_ips_from_terraform.py -i libs/terraform/gce-tutorial

#install cm and install cluster
#ansible-playbook playbook/cm.yml -i libs/inventories/gce/ -l tag_$MASTER_TAG -u $USERNAME --private-key=$PRIVATEKEY


###END OF CORE INSTALLATION 
