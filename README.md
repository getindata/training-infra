# Setup

```
pip install ansible
ansible-galaxy install -r requirements.yml

# cp example-hosts hosts

# Edit hosts to represent your hosts

ansible-playbook playbook/bootstrap.yml -i hosts -u <username> --private-key <path to private key>

ansible-playbook playbook/devenv.yml -i hosts -u <username> --private-key <path to private key>
ansible-playbook playbook/setup-user.yml -i hosts -u <username> --private-key <path to private key>
ansible-playbook playbook/selinux-disable.yml -i hosts -u <username> --private-key <path to private key>

ansible-playbook playbook/cm.yml -i hosts -u <username> --private-key <path to private key>

```
