rpm --import http://packages.confluent.io/rpm/2.0/archive.key


cat <<EOF > /etc/yum.repos.d/confluent.repo
[confluent-2.0]
name=Confluent repository for 2.0.x packages
baseurl=http://packages.confluent.io/rpm/2.0
gpgcheck=1
gpgkey=http://packages.confluent.io/rpm/2.0/archive.key
enabled=1
EOF

## Cannot install whole confluent-platform on Redhat 6.5. We need to install packages manually.
# sudo yum install confluent-platform-2.11.7

yum install -y confluent-kafka-2.11.7 confluent-schema-registry confluent-camus
