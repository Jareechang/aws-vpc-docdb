variable "aws_region" {
    default = "us-east-1"
}
variable "local_ip_address" {}


variable "docdb_cluster_identifer" {
    default = "dev"
}

variable "docdb_cluster_username" {
    default = "dev_user"
}

variable "lambda_func_name" {
    default = "lambda-docdb-access"
}
