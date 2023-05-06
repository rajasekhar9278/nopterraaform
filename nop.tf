variable "awsvar" {
    type = "map"
    default = {
        region = us-east-1
        vpc = "vpc-245678d"
        ami = "ami-0c1bea58988a989155"
        itype = "t2.micro"
        subnet = "subnet-81896c8e"
        publicip = true
        keyname = mykey
        secgroupname = "IAC-Sec-Group"
    }
}

provider "aws" {
    region = lookup(var.awsvar, "region")  
}

resource "awssecuritygroup" "project-iac-sg" {
    name = lookup(var.awsvar, "secgroupname")
    description = lookup(var.awsvar, "secgroupname")
    vpc_id = lookup(var.awsvar, "vpc")

    // To Allow SSH Transport
    ingress {
        from_port = 22
        protocal = "tcp"
        to_port = 22
        cidr_blocks = ["10.0.0.0/16"]
    }

    // To Allow Port 80 Transport
    ingress {
        from_port = 80
        protocal = ""
        to_port = 80
        cidr_blocks = ["172.31.0.0/16"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocal = "-1"
        cidr_blocks = ["192.168.0.0/20"]
    }
    lifecycle {
      create_before_destroy = true
    } 
}

resource "aws_instance" "project-iac" {
    ami = lookup(var.awsvar, "ami")
    instance_type = lookup(var.awsvar, "itype")
    subnet_id = lookup(var.awsvar, "subnet")
    associate_public_ip_address = lookup(var.awsvar, "publicip")
    key_name = lookup(var.awsvar, "keyname")

    vpc_security_group_ids = [
        aws_security_group.project-iac-sg.id
    ]
    root_block_device {
      delete_on_termination = true
      iops = 150
      volume_size = 50
      volume_type = "gp2"
    }
    tags = {
        name = "SERVER"
        Environment = "DEV"
        OS = "UBUNTU"
        Managed = "IAC"
    }

    depends_on = [ awssecuritygroup.project-iac-sg ]
}


output "ec2instance" {
    value = aws_instance.project-iac.public_ip 
}