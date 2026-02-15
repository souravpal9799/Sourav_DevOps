output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = local.private_subnet_ids
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = local.public_subnet_ids
  description = "Public subnet IDs (EKS cluster and nodes use these)"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
  description = "Base64-encoded CA certificate for the cluster"
}

output "configure_kubectl" {
  value       = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${module.eks.cluster_name}"
  description = "Run this command to configure kubectl"
}

# Expose region for configure_kubectl
data "aws_region" "current" {}
