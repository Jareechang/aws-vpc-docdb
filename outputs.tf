output "ssh-key" {
    value = tls_private_key.dev.private_key_pem
}

output "bastion_instance_ip" {
    value = aws_instance.bastion.public_ip
}

output "private_instance_ip" {
    value = aws_instance.dev.private_ip
}
