output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "execution_role_arn" {
  description = "ARN of the function's execution role - attach extra permissions here."
  value       = aws_iam_role.lambda_execution.arn
}

output "function_url" {
  description = "HTTPS function URL, or null when enable_function_url is false."
  value       = var.enable_function_url ? aws_lambda_function_url.this[0].function_url : null
}
