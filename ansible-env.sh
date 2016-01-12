# please dot source the file to be able to use ansible.
id_rsa_ansible=files/id_rsa_ansible
if [ ! -S "$SSH_AUTH_SOCK" ] ; then
   eval `ssh-agent -s`
fi
# Enter passphrase to ansible key.
chmod 400 "$id_rsa_ansible"
ssh-add "$id_rsa_ansible"

