# Expects a secret that already exists and is already populated (e.g. via
# `aws secretsmanager put-secret-value`) - referenced here, never created or
# managed as a resource, so Terraform never sees/stores the actual values.
data "aws_secretsmanager_secret" "backend_env" {
  name = var.backend_secret_name
}

data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

# Additive only: grants the existing execution role read access to this one
# secret, without touching its trust policy or any other existing permission.
resource "aws_iam_role_policy" "read_backend_secret" {
  name = "${var.name_prefix}-read-backend-secret"
  role = var.execution_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [data.aws_secretsmanager_secret.backend_env.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = [data.aws_kms_alias.secretsmanager.target_key_arn]
      }
    ]
  })
}
