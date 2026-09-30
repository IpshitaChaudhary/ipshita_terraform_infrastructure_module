# Deliberately opt-in and scoped, same pattern as the sqs module - a real
# account audit found SNS-adjacent misconfigurations account-wide, and this
# module never generates a policy at all unless the caller explicitly lists
# who's allowed to publish/subscribe.
data "aws_iam_policy_document" "this" {
  count = length(var.allowed_publisher_arns) > 0 || length(var.allowed_subscriber_arns) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = length(var.allowed_publisher_arns) > 0 ? [1] : []
    content {
      sid     = "AllowScopedPublish"
      actions = ["sns:Publish"]

      principals {
        type        = "AWS"
        identifiers = var.allowed_publisher_arns
      }

      resources = [aws_sns_topic.this.arn]
    }
  }

  dynamic "statement" {
    for_each = length(var.allowed_subscriber_arns) > 0 ? [1] : []
    content {
      sid     = "AllowScopedSubscribe"
      actions = ["sns:Subscribe"]

      principals {
        type        = "AWS"
        identifiers = var.allowed_subscriber_arns
      }

      resources = [aws_sns_topic.this.arn]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  count = length(var.allowed_publisher_arns) > 0 || length(var.allowed_subscriber_arns) > 0 ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this[0].json
}
