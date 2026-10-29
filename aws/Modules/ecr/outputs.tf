output "backend_repository_url" {
  description = "Full URL of the backend repository, used as the image prefix in task definitions."
  value       = data.aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "Full URL of the frontend repository, used as the image prefix in task definitions."
  value       = data.aws_ecr_repository.frontend.repository_url
}
