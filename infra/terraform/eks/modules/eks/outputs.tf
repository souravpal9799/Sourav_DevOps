output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  value     = aws_eks_cluster.this.certificate_authority[0].data
  sensitive = true
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_issuer_url" {
  value = length(aws_eks_cluster.this.identity) > 0 && length(aws_eks_cluster.this.identity[0].oidc) > 0 ? aws_eks_cluster.this.identity[0].oidc[0].issuer : null
}
