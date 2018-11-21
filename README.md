# Onboard training users and data on existing cluster

The playbook `playbook/training-setup.yml` is responsible for
* creating user accounts
* uploaded trainig datasets in HDFS and creating training Hive tables
* install necessary client Linux libraries on the edge
It runs all above activities on the `edge` node.
It can also onboard HUE users (by executing the `hue-users` role) - make sure that `hosts` points to the node that has HUE installed (e.g. edge or master)

```
ansible-playbook playbook/training-setup.yml -i ${HOSTS_FILE} -u ${USERNAME} --private-key ${PRIVATE_KEY}
```


# Build a training cluster

```
./one-command-cm-cluster.sh terraform-clusters/developer-cdh
```

# Setup

```
pip install ansible
ansible-galaxy install -r requirements.yml
```

```
ansible-playbook playbook/kylo.yml -i inventories/training-cdh -u root -k
```
