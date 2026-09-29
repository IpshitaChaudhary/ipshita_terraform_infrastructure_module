locals {
  # FIFO queue names must end in .fifo - enforced here rather than trusting
  # every caller to remember it.
  queue_name = var.fifo_queue ? "${var.name_prefix}-queue.fifo" : "${var.name_prefix}-queue"
  dlq_name   = var.fifo_queue ? "${var.name_prefix}-dlq.fifo" : "${var.name_prefix}-dlq"
}

resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name       = local.dlq_name
  fifo_queue = var.fifo_queue

  # No redrive on the DLQ itself, and encrypted the same way as the main
  # queue - a DLQ holding unencrypted poison messages defeats the point of
  # encrypting the main queue.
  sqs_managed_sse_enabled = var.kms_master_key_id == null
  kms_master_key_id       = var.kms_master_key_id
}

resource "aws_sqs_queue" "this" {
  name       = local.queue_name
  fifo_queue = var.fifo_queue

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds

  sqs_managed_sse_enabled = var.kms_master_key_id == null
  kms_master_key_id       = var.kms_master_key_id

  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null
}
