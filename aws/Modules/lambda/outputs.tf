output "function_arn" {
  value = aws_lambda_function.this.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "execution_role_arn" {
  value = aws_iam_role.lambda_execution.arn
}

output "function_url" {
  value = var.enable_function_url ? aws_lambda_function_url.this[0].function_url : null
}
