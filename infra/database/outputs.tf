output "docdb_cluster_endpoint" {
    value = aws_docdb_cluster.default.endpoint
}

output "docdb_cluster_username" {
    value = var.docdb_cluster_username
}

output "docdb_cluster_password" {
    value = random_password.docdb_password.result
}
