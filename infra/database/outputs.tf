output "db_endpoint" {
    value = aws_docdb_cluster.default.endpoint
}

output "db_username" {
    value = var.docdb_cluster_username
}

output "db_password" {
    value = random_password.docdb_password.result
}
