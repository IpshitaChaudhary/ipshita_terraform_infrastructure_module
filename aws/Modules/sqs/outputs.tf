output "queue_arn" {
  description = "ARN of the main queue."
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "URL of the main queue - what SDK send/receive calls take."
  value       = aws_sqs_queue.this.id
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue, or null when enable_dlq is false."
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}
