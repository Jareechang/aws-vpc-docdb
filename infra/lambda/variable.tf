variable "aws_region" {
    default = "us-east-1"
}

variable "lambda_func_name" {
    default = "lambda-docdb-access"
}

variable "s3_bucket_name" {}

variable "docdb_cluster_username" {}
variable "docdb_cluster_password" {}
variable "docdb_cluster_endpoint" {}

variable "db_subnet_1a_id" {}
variable "db_subnet_1b_id" {}
variable "default_sg_custom_id" {}
