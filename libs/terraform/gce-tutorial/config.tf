provider "google" {
    credentials = "${file("getindatatraining.json")}"
    project = "getindata-training"
    region = "us-east1-d"
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
    tags = ["amaster",]


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
            user = "piotrektt"
            key_file = "pbatgetindata"
        }
    }
}

resource "google_compute_instance" "mastersmall" {
    disk = {
        image = "centos-7-v20160418"
        size = "40"
        type = "pd-standard"
    }
    name = "master-small-${count.index + 1}"
    machine_type = "n1-standard-1"
    count = 0 
    zone = "us-east1-d"


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
            user = "piotrektt"
            key_file = "pbatgetindata"
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
    count = 5 
    zone = "us-east1-d"
    tags = ["aslave",]

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
            user = "piotrektt"
            private_key = "pbatgetindata"
        }
    }
}

resource "google_compute_instance" "slavea" {
    disk = {
        image = "centos-7-v20160418"
        size = "100"
        type = "pd-standard"
    }
    name = "slave-a-${count.index + 1}"
    machine_type = "n1-standard-1"
    count = 5 
    zone = "us-east1-d"
    tags = ["aslavea",]

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
            user = "piotrektt"
            private_key = "pbatgetindata"
        }
    }
}


resource "google_compute_instance" "slave-medium" {
    disk = {
        image = "centos-7-v20160418"
        size = "40"
        type = "pd-standard"
    }
    name = "slave-medium-${count.index + 1}"
    machine_type = "n1-standard-2"
    count = 0
    zone = "us-east1-d"

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
            user = "piotrektt"
            private_key = "pbatgetindata"
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
    tags = ["aedge",]


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
            user = "piotrektt"
            key_file = "pbatgetindata"
        }
    }
}


resource "google_compute_instance" "edge-1" {
    disk = {
        image = "centos-7-v20160418"
        size = "100"
        type = "pd-standard"
    }
    name = "edge-1"
    machine_type = "n1-standard-2"
    count = 1 
    zone = "us-east1-d"
    tags = ["aedgea",]


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
            user = "piotrektt"
            key_file = "pbatgetindata"
        }
    }
}

