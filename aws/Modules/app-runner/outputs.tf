output "service_arn" {
  value = aws_apprunner_service.this.arn
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}

output "instance_role_arn" {
  value = aws_iam_role.instance.arn
}
