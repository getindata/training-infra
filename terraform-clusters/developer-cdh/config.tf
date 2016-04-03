provider "aws" {
    access_key = "AKIAJPKNSSRXWVZO3GYQ"
    secret_key = "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"
    region = "us-west-2"
}

resource "aws_instance" "cdh-edge" {
    ami = "ami-4dbf9e7d"
#    ami = "ami-2cf8901c"
    instance_type = "m3.xlarge"
    count = 1
    key_name = "oregon"

    root_block_device {
        volume_size = 40
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y ntp",
            "sudo systemctl enable ntpd",
            "sudo systemctl start ntpd",
            "sudo /sbin/chkconfig ntpd on",
            "sudo /etc/init.d/ntpd start",
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm",
            "sudo yum -y update",
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "ec2-user"
            key_file = "oregon.pem"
        }
    }
}


resource "aws_instance" "cdh-master" {
    ami = "ami-4dbf9e7d"
#    ami = "ami-2cf8901c"
    instance_type = "m3.large"
    count = 1
    key_name = "oregon"

    root_block_device {
        volume_size = 40
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y ntp",
            "sudo systemctl enable ntpd",
            "sudo systemctl start ntpd",
            "sudo /sbin/chkconfig ntpd on",
            "sudo /etc/init.d/ntpd start",
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm",
            "sudo yum -y update",
            "sudo yum -y install python-pip",
            "sudo pip install --upgrade pip",
        ]
        connection {
            user = "ec2-user"
            key_file = "oregon.pem"
        }
    }
}

resource "aws_instance" "cdh-slave" {
    ami = "ami-4dbf9e7d"
#    ami = "ami-2cf8901c"
    instance_type = "m3.large"
    count = 1
    key_name = "oregon"

    root_block_device {
        volume_size = 40
    }

   provisioner "remote-exec" {
        inline = [
            "sudo yum install -y ntp",
            "sudo systemctl enable ntpd",
            "sudo systemctl start ntpd",
            "sudo /sbin/chkconfig ntpd on",
	    "sudo /etc/init.d/ntpd start",
            "sudo yum -y upgrade openssl",
            "sudo yum -y install wget",
            "sudo rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm",
            "sudo yum -y update",
            "sudo yum install -y python-pip",
            "sudo pip install --upgrade pip",
       ]
       connection {
            user = "ec2-user"
            key_file = "oregon.pem"
       }
  }
}
