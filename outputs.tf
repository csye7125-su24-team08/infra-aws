# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

output "eks_kubectl_connect" {
  description = "Command to connect to the EKS cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name} --profile profile-name"
}

output "postgres_password" {
  description = "value of the postgres password"
  value       = module.postgres_chart.postgresPassword
}
