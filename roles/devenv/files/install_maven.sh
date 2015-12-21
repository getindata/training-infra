#!/bin/bash

install-maven() {
    MAVEN_FILE=apache-maven-3.0.5-bin.tar.gz
    rm -rf ${MAVEN_FILE}
    rm -rf /usr/local/apache-maven-3.0.5-bin
    rm -rf /usr/local/maven

    wget http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.0.5/binaries/${MAVEN_FILE}
    tar xzf ${MAVEN_FILE} -C /usr/local
    ln -s /usr/local/apache-maven-3.0.5 /usr/local/maven

    echo "export M2_HOME=/usr/local/maven" > /etc/profile.d/maven.sh
    echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /etc/profile.d/maven.sh
    rm ${MAVEN_FILE}
}

install-maven
