output "alb_dns_name" {
  description = "DNS name of the ALB - point the app's DNS records here."
  value       = module.loadbalancer.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.capacity.cluster_name
}

output "backend_service_name" {
  description = "Name of the backend ECS service, for deploy pipelines."
  value       = module.backend_service.service_name
}

output "frontend_service_name" {
  description = "Name of the frontend ECS service, for deploy pipelines."
  value       = module.frontend_service.service_name
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL, for CI to push images to."
  value       = module.ecr.backend_repository_url
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL, for CI to push images to."
  value       = module.ecr.frontend_repository_url
}
