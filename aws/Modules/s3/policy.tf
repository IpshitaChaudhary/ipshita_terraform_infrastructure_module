# Same opt-in, scoped philosophy as the sqs/sns modules. Note this is
# layered UNDER the Public Access Block in main.tf, not instead of it -
# block_public_policy there means even an accidentally-broad statement here
# still can't make the bucket public; this is defense in depth, not the
# only line of defense.
data "aws_iam_policy_document" "this" {
  count = length(var.allowed_principal_arns) > 0 ? 1 : 0

  statement {
    sid     = "AllowScopedAccess"
    actions = var.allowed_actions

    principals {
      type        = "AWS"
      identifiers = var.allowed_principal_arns
    }

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = length(var.allowed_principal_arns) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}
