# Explicit log group with a real retention period - left to Lambda's
# default, a function's log group is created automatically with NO
# expiration at all, which is how log storage costs quietly grow forever
# on a function nobody remembers exists.
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name_prefix}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "this" {
  function_name = var.name_prefix
  role          = aws_iam_role.lambda_execution.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = var.filename
  source_code_hash = var.filename != null ? filebase64sha256(var.filename) : null
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key

  environment {
    variables = var.environment_variables
  }

  # Forces the log group to exist (with its real retention) before the
  # function can write to it, instead of racing Lambda's own
  # auto-creation of a no-expiry group.
  depends_on = [aws_cloudwatch_log_group.this]
}
