output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "HTTPS endpoint of the Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA certificate, needed by kubeconfig and the kubernetes/helm providers."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group EKS created for the control plane and managed nodes."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider, used in IRSA trust policies."
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "Issuer URL of the OIDC provider (without https://), used in IRSA trust policy conditions."
  value       = aws_iam_openid_connect_provider.cluster.url
}

output "node_role_arn" {
  description = "IAM role of the managed node group."
  value       = aws_iam_role.node.arn
}

output "node_group_name" {
  description = "Name of the managed node group."
  value       = aws_eks_node_group.this.node_group_name
}

output "secrets_kms_key_arn" {
  description = "KMS key used to envelope-encrypt Kubernetes Secrets (module-created or the one passed in)."
  value       = local.secrets_kms_key_arn
}
