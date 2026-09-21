output "alb_dns_name" {
  value = module.loadbalancer.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.capacity.cluster_name
}

output "backend_service_name" {
  value = module.backend_service.service_name
}

output "frontend_service_name" {
  value = module.frontend_service.service_name
}

output "backend_ecr_repository_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_ecr_repository_url" {
  value = module.ecr.frontend_repository_url
}
