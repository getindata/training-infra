variable "name-prefix" {
  type    = string
  default = "dev-cdh"
}


variable "master-count" {
  type    = string
  default = "1"
}

variable "edge-count" {
  type    = string
  default = "1"
}

variable "slave-count" {
  type    = string
  default = "4"
}

variable "master-instance-type" {
  type    = string
  default = "n1-standard-4"
}

variable "edge-instance-type" {
  type    = string
  default = "n1-highmem-2"
}

variable "slave-instance-type" {
  type    = string
  default = "n1-highmem-2"
}

variable "google-cloud-region" {
  type    = string
  default = "us-east1-d"
}

variable "google-cloud-image" {
  type    = string
  default = "centos-7-v20180129"
}

variable "google-cloud-network" {
  type    = string
  default = "cdh-training-us-east1"
}

variable "provisioning-commands" {
  default = [
    "sudo yum -q makecache -y --disablerepo='google-cloud-compute' --enablerepo=google-cloud-compute",
    "sudo yum -y install wget",
    "sudo yum -y install epel-release",
    "sudo yum -y install python-pip",
    "sudo pip install --upgrade pip",
  ]
}

variable "private-key-file" {
  type    = string
  default = "./id_rsa_training"
}


