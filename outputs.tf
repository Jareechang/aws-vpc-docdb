data "aws_caller_identity" "current" {}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "ssh-key" {
    value = tls_private_key.dev.private_key_pem
}

output "bastion_instance_ip" {
    value = aws_instance.bastion.public_ip
}

output "private_instance_ip" {
    value = aws_instance.dev.private_ip
}

output "docdb_password" {
    value = random_password.docdb_password 
}
