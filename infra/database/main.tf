resource "aws_security_group" "private_db_docdb" {
  name        = "sg_custom_db_default"
  description = "Custom default SG"
  vpc_id      = "${var.vpc_id}"

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

# DB - DocumentDB

# Default DB subnet group
resource "aws_docdb_subnet_group" "default" {
    name       = "main"
    subnet_ids = [
        var.db_subnet_1a_id,
        var.db_subnet_1b_id,
    ]

    tags = {
        Name = "Dev-Docdb-subnet-group"
    }
}

resource "random_password" "docdb_password" {
    length = 16
    special = false 
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
