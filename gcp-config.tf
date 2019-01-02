provider "google" {
    credentials = "${file("getindatatraining.json")}"
    project = "getindata-training"
    region = "us-east1-d"
}

resource "google_compute_instance" "master" {
    disk = {
        image = "centos-7-v20180129"
        size = "60"
        type = "pd-standard"
    }
    name = "master-large-${count.index + 1}"
    machine_type = "n1-standard-4"
    count = 1
    zone = "us-east1-d"
    tags = ["master",]


    network_interface {
        network = "default"
        access_config {
                // Ephemeral IP
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm",
            "sudo yum -y update",
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "admin"
            key_file = "adminkey"
        }
    }
}


resource "google_compute_instance" "master-medium" {
    disk = {
        image = "centos-7-v20180129"
        size = "60"
        type = "pd-standard"
    }
    name = "master-medium-${count.index + 1}"
    machine_type = "n1-standard-2"
    count = 0
    zone = "us-east1-d"
    tags = ["mastermedium",]


    network_interface {
        network = "default"
        access_config {
                // Ephemeral IP
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm",
            "sudo yum -y update",
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "admin"
            key_file = "adminkey"
        }
    }
}


resource "google_compute_instance" "slave" {
    disk = {
        image = "centos-7-v20180129"
        size = "100"
        type = "pd-standard"
    }
    name = "slave-${count.index + 1}"
    machine_type = "n1-standard-1"
    count = 3 
    zone = "us-east1-d"
    tags = ["slave",]

    network_interface {
        network = "default"
        access_config {
                // Ephemeral IP
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm",
            "sudo yum -y update",
        ]
        connection {
            user = "admin"
            private_key = "adminkey"
        }
    }
}

resource "google_compute_instance" "slave-medium" {
    disk = {
        image = "centos-7-v20180129"
        size = "100"
        type = "pd-standard"
    }
    name = "slave-medium-${count.index + 1}"
    machine_type = "n1-standard-2"
    count = 0
    zone = "us-east1-d"
    tags = ["slavemedium",]

    network_interface {
        network = "default"
        access_config {
                // Ephemeral IP
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm",
            "sudo yum -y update",
        ]
        connection {
            user = "admin"
            private_key = "adminkey"
        }
    }
}

resource "google_compute_instance" "edge" {
    disk = {
        image = "centos-7-v20180129"
        size = "100"
        type = "pd-standard"
    }
    name = "edge-${count.index + 1}"
    machine_type = "n1-standard-1"
    count = 1
    zone = "us-east1-d"
    tags = ["edge",]


    network_interface {
        network = "default"
        access_config {
                // Ephemeral IP
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm",
            "sudo yum -y update",
        ]
        connection {
            user = "admin"
            key_file = "adminkey"
        }
    }
}
