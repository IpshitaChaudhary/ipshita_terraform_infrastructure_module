output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ARN of the task definition revision Terraform created. CI/CD registers newer revisions after this."
  value       = aws_ecs_task_definition.this.arn
}
