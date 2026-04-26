output "region" {
  description = "AWS region"
  value       = var.region
}

output "k8s_node_public_ip" {
  description = "Public IP of the MicroK8s Node"
  value       = aws_eip.k8s_node_eip.public_ip
}

output "k8s_node_private_key" {
  description = "Private key for the MicroK8s Node"
  value       = tls_private_key.k8s_node_key.private_key_pem
  sensitive   = true
}
