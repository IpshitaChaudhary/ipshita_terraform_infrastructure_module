# Deliberately opt-in and scoped - a real account audit found SQS queues
# with wildcard Principal:"*" policies, which makes a queue publicly
# writable/readable by anyone. This module never generates a policy at all
# unless var.allowed_sender_arns is non-empty, and even then it only grants
# sqs:SendMessage (never the full queue) to the specific ARNs given, scoped
# to this exact queue's ARN as the condition source.
data "aws_iam_policy_document" "this" {
  count = length(var.allowed_sender_arns) > 0 ? 1 : 0

  statement {
    sid     = "AllowScopedSendMessage"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "AWS"
      identifiers = var.allowed_sender_arns
    }

    resources = [aws_sqs_queue.this.arn]
  }
}

resource "aws_sqs_queue_policy" "this" {
  count = length(var.allowed_sender_arns) > 0 ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = data.aws_iam_policy_document.this[0].json
}
