schema-registry-start -daemon /etc/schema-registry/schema-registry.properties
zookeeper-server-start -daemon /etc/kafka/zookeeper.properties
kafka-server-start -daemon /etc/kafka/server.properties
