# Setup

```
pip install ansible
ansible-galaxy install -r requirements.yml


# cp example-hosts hosts
# Edit hosts to represent your hosts

ansible-playbook playbook/bootstrap.yml -i hosts --private-key <path to private key>
```
