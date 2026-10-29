output "backend_env_secret_arn" {
  description = "ARN of the backend environment secret, referenced in the task definition's secrets block."
  value       = data.aws_secretsmanager_secret.backend_env.arn
}

output "backend_env_secret_name" {
  description = "Name of the backend environment secret."
  value       = data.aws_secretsmanager_secret.backend_env.name
}
