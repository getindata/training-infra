#PART 1 
#use terraform to request machines for cluster
#./one-command-step.sh aws terraform-clusters/test-google-piotrek/

#setup for all hosts on google cloud
#ansible-playbook playbook/bootstrap_gce.yml -i inventories/gce/ -l tag_aedgea -u piotrektt --private-key=pbatgetindata
#ansible-playbook playbook/devenv.yml -i inventories/gce -l tag_aedgea -u piotrektt --private-key=pbatgetindata
#ansible-playbook playbook/setup-user.yml -i inventories/gce -l tag_aedgea -u piotrektt --private-key=pbatgetindata
#ansible-playbook playbook/selinux-disable.yml -i inventories/gce -l tag_aedgea -u piotrektt --private-key=pbatgetindata
#echo "Waiting for machines reboot"
#sleep 120

#get gce hosts internal-ips
#./get_gce_ips_from_terraform.py -i terraform-clusters/test-google-piotrek

#install cm and install cluster
#ansible-playbook playbook/cm.yml -i inventories/gce/ -l tag_amaster -u piotrektt --private-key=pbatgetindata



