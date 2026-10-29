output "cluster_id" {
  description = "ID (ARN) of the ECS cluster."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster, for services and deploy pipelines to target."
  value       = aws_ecs_cluster.this.name
}

output "capacity_provider_name" {
  description = "Name of the ASG-backed capacity provider, used in each service's capacity_provider_strategy."
  value       = aws_ecs_capacity_provider.this.name
}
