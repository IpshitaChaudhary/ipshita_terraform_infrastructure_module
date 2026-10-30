data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# Envelope encryption for Kubernetes Secrets. Without it, Secrets sit in etcd
# encrypted only by the EBS layer AWS manages - anyone who can read etcd (or a
# backup of it) reads them in plaintext. With it, the API server encrypts each
# Secret with a data key that is itself encrypted by this KMS key.
#
# Bring your own key with secrets_kms_key_arn, or leave it null and the module
# creates a dedicated one with yearly rotation.
locals {
  create_kms_key      = var.secrets_kms_key_arn == null
  secrets_kms_key_arn = local.create_kms_key ? aws_kms_key.secrets[0].arn : var.secrets_kms_key_arn
}

data "aws_iam_policy_document" "secrets_kms" {
  count = local.create_kms_key ? 1 : 0

  # Account-level admin, so the key can never become unmanageable if the
  # cluster role is deleted first.
  statement {
    sid       = "AccountAdmin"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Only what the control plane needs to wrap/unwrap data keys.
  statement {
    sid = "EksClusterUse"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cluster.arn]
    }
  }
}

resource "aws_kms_key" "secrets" {
  count = local.create_kms_key ? 1 : 0

  description             = "${var.name_prefix}-eks envelope encryption for Kubernetes Secrets"
  enable_key_rotation     = true
  deletion_window_in_days = var.secrets_kms_deletion_window_days
  policy                  = data.aws_iam_policy_document.secrets_kms[0].json
}

resource "aws_kms_alias" "secrets" {
  count = local.create_kms_key ? 1 : 0

  name          = "alias/${var.name_prefix}-eks-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}
