output "backend_env_secret_arn" {
  value = data.aws_secretsmanager_secret.backend_env.arn
}

output "backend_env_secret_name" {
  value = data.aws_secretsmanager_secret.backend_env.name
}
