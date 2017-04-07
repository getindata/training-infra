provider "google" {
    credentials = "${file("gce-tutorial.json")}"
    project = "gce-tutorial"
    region = "us-east1"
}

resource "google_compute_instance" "master" {
    disk = { 
	image = "centos-7-v20160418" 
	size = "60"	
        type = "pd-standard"
    }
    name = "master-large"
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
            user = "gce-user"
            key_file = "gce-key"
        }
    }
}

resource "google_compute_instance" "slave" {
    disk = {
        image = "centos-7-v20160418"
        size = "100"
        type = "pd-standard"
    }
    name = "slave-${count.index + 1}"
    machine_type = "n1-standard-1"
    count = 2 
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
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "gce-user"
            private_key = "gce-key"
        }
    }
}

resource "google_compute_instance" "edge" {
    disk = {
        image = "centos-7-v20160418"
        size = "100"
        type = "pd-standard"
    }
    name = "edge"
    machine_type = "n1-standard-2"
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
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "gce-user"
            key_file = "gce-key"
        }
    }
}
