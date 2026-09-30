locals {
  # FIFO topic names must end in .fifo - enforced here rather than trusting
  # every caller to remember it.
  topic_name = var.fifo_topic ? "${var.name_prefix}-topic.fifo" : "${var.name_prefix}-topic"
}

resource "aws_sns_topic" "this" {
  name              = local.topic_name
  fifo_topic        = var.fifo_topic
  kms_master_key_id = var.kms_master_key_id
}
