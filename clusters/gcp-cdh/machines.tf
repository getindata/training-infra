provider "google" {
    credentials = file("getindatatraining.json")
    project = "getindata-training"
    zone = var.google-cloud-region
}


resource "google_compute_instance" "master" {
    boot_disk  {
         initialize_params {
             image = var.google-cloud-image
             size = "60"
             type = "pd-standard"
        }
    }

    name = "${var.name-prefix}-master-0${count.index + 1}"
    machine_type = var.master-instance-type
    count = var.master-count
    tags = ["master","${var.name-prefix}-training"]

    network_interface {
        subnetwork = var.google-cloud-network
        access_config { }
    }

    provisioner "remote-exec" {
        inline = var.provisioning-commands
        connection {
            type = "ssh"
            user = "admin"
            private_key = file("${var.private-key-file}")
            host = self.network_interface.0.access_config.0.nat_ip
        }
    }
}

resource "google_compute_instance" "edge" {
    boot_disk {
         initialize_params {
             image = var.google-cloud-image
             size = "100"
             type = "pd-standard"
        }
    }

    name = "${var.name-prefix}-edge-0${count.index + 1}"
    machine_type = var.edge-instance-type
    count = var.edge-count
    tags = ["edge","${var.name-prefix}-training"]

    network_interface {
        subnetwork = var.google-cloud-network
        access_config { }
    }

    provisioner "remote-exec" {
        inline =  var.provisioning-commands
        connection {
            type = "ssh"
            user = "admin"
            private_key = file("${var.private-key-file}")
            host = self.network_interface.0.access_config.0.nat_ip
        }
    }
}

resource "google_compute_instance" "slave" {
    boot_disk {
         initialize_params {
             image = var.google-cloud-image
             size = "100"
             type = "pd-standard"
        }
    }

    name = "${var.name-prefix}-slave-0${count.index + 1}"
    machine_type = var.slave-instance-type
    count = var.slave-count
    tags = ["slave","${var.name-prefix}-training"]

    network_interface {
        subnetwork = var.google-cloud-network
        access_config { }
    }

    provisioner "remote-exec" {
        inline =  var.provisioning-commands
        connection {
            type = "ssh"
            user = "admin"
            private_key = file("${var.private-key-file}")
            host = self.network_interface.0.access_config.0.nat_ip
        }
    }
}


