provider "aws" {
    version = "~> 3.12.0"
    region  = "${var.aws_region}"
}

provider "random" {
    version = "~> 2.2.0"
}


## Key Pair
resource "tls_private_key" "dev" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev" {
    key_name   = "dev-key"
    public_key = tls_private_key.dev.public_key_openssh
}


## VPC
resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "vpc-test"
    }
}

## Public
resource "aws_subnet" "public_1a" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "public-1a"
    }
}

resource "aws_subnet" "public_1b" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "public-1b"
    }
}


## Private

## App subnets 

resource "aws_subnet" "app_1a" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "app-1a"
    }
}

resource "aws_subnet" "app_1b" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.12.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "app-1b"
    }
}

resource "aws_subnet" "db_1a" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.21.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "db-1a"
    }
}

resource "aws_subnet" "db_1b" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.22.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "db-1b"
    }
}

## IGW
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw-main"
    }
}

## Routing
resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "rt-public-1a"
    }
}

resource "aws_route_table_association" "public_1a" {
    subnet_id      = aws_subnet.public_1a.id
    route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "public_1b" {
    subnet_id      = aws_subnet.public_1b.id
    route_table_id = aws_route_table.rt_public.id
}

## Security Group - bastion
resource "aws_security_group" "bastion" {
  name        = "sg_bastion"
  description = "Custom default SG for Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
      description = "TLS from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${var.local_ip_address}/32"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "web-bastion-sg"
  }
}

resource "aws_default_security_group" "custom_default" {
  vpc_id      = aws_vpc.main.id

  ingress {
      protocol  = -1
      self      = true
      from_port = 0
      to_port   = 0
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "web-custom-default"
  }
}


## Security Group - default private (The default SG for private resources)
resource "aws_security_group" "private_default" {
  name        = "sg_custom_default"
  description = "Custom default SG"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
      description = "TLS from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      security_groups = [
          "${aws_security_group.bastion.id}"
      ]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "allow_tls"
  }
}

resource "aws_security_group" "private_db_docdb" {
  name        = "sg_custom_db_default"
  description = "Custom default SG"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
      description = "TLS from VPC"
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "allow_db_connection"
  }
}

## Network ACL

resource "aws_network_acl" "private_default" {
  vpc_id      = "${aws_vpc.main.id}"

  egress {
      rule_no    = 100
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      action     = "allow"
      cidr_block = aws_vpc.main.cidr_block
  }

  ingress {
      rule_no    = 100
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      action     = "allow"
      cidr_block = aws_vpc.main.cidr_block
  }

  tags = {
      Name = "nacl-private-default"
  }
}

## EC2 Instance
data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }
}



# EC2 - Public
resource "aws_instance" "bastion" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_1a.id
    vpc_security_group_ids = [
        aws_security_group.bastion.id
    ]
    associate_public_ip_address = true
    user_data = <<EOF
        #! /bin/bash
        yum update -y
        touch /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "[mongodb-org-4.4]" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.4/x86_64/" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "enabled=1" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc" >> /etc/yum.repos.d/mongodb-org-4.4.repo
        yum install mongodb-org-shell-4.4.1 -y
        wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
    EOF
    key_name = aws_key_pair.dev.key_name
    tags = {
        Name = "Bastion-Instance"
    }
}

# EC2 - Private
resource "aws_instance" "dev" {
    ami = data.aws_ami.amazon_linux_2.id
    subnet_id = aws_subnet.app_1a.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [
        aws_security_group.private_default.id
    ]
    key_name = aws_key_pair.dev.key_name
    tags = {
        Name = "Dev-Instance-1a"
    }
}

# DB - DocumentDB

# Default DB subnet group
resource "aws_docdb_subnet_group" "default" {
    name       = "main"
    subnet_ids = [
        aws_subnet.db_1a.id,
        aws_subnet.db_1b.id
    ]

    tags = {
        Name = "Dev-Docdb-subnet-group"
    }
}

resource "random_password" "docdb_password" {
    length = 16
    special = true
    override_special = "_%@"
}

resource "aws_docdb_cluster" "default" {
    cluster_identifier      = var.docdb_cluster_identifer 
    master_username         = var.docdb_cluster_username
    master_password         = random_password.docdb_password.result
    backup_retention_period = 1
    preferred_backup_window = "07:00-09:00"
    skip_final_snapshot     = true
    port                    = 27017
    availability_zones      = [
        "us-east-1a",
        "us-east-1b"
    ]
    db_subnet_group_name    = aws_docdb_subnet_group.default.id
    vpc_security_group_ids  = [
        aws_security_group.private_db_docdb.id
    ]
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
    count              = 2
    identifier         = "${var.docdb_cluster_identifer}-${count.index}"
    cluster_identifier = aws_docdb_cluster.default.id
    instance_class     = "db.t3.medium"
}
