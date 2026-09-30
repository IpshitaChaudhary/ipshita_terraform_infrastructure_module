data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Least-privilege by construction: the base role only gets what every
# Lambda function needs (write its own CloudWatch Logs) - a real account
# audit found a Lambda execution role with wildcard cognito-idp:*/sns:*
# grants on Resource:* baked in as inline policies, far broader than the
# function actually needed. Anything beyond logging must be added
# explicitly per caller via extra_execution_policy_arns, scoped to the
# specific resource that function touches.
resource "aws_iam_role" "lambda_execution" {
  name               = "${var.name_prefix}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_execution_extra" {
  for_each   = toset(var.extra_execution_policy_arns)
  role       = aws_iam_role.lambda_execution.name
  policy_arn = each.value
}
