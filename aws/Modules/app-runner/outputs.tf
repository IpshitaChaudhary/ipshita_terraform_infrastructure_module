output "service_arn" {
  description = "ARN of the App Runner service."
  value       = aws_apprunner_service.this.arn
}

output "service_url" {
  description = "Default HTTPS URL App Runner assigns to the service (without the https:// scheme)."
  value       = aws_apprunner_service.this.service_url
}

output "instance_role_arn" {
  description = "ARN of the instance role the running container assumes - attach extra permissions here."
  value       = aws_iam_role.instance.arn
}
