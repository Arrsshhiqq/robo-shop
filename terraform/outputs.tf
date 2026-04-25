output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "ci_server_public_ip" {
  description = "Public IP of the CI Server"
  value       = aws_eip.ci_server_eip.public_ip
}

output "ci_server_private_key" {
  description = "Private key for the CI Server"
  value       = tls_private_key.ci_server_key.private_key_pem
  sensitive   = true
}
