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

output "db_subnet_1a_id" {
    value = aws_subnet.db_1a.id 
}

output "db_subnet_1b_id" {
    value = aws_subnet.db_1b.id 
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "default_sg_custom_id" {
    value = aws_default_security_group.custom_default.id
}
