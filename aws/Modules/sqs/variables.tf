variable "name_prefix" {
  description = "Prefix applied to the queue name(s) this module creates."
  type        = string
}

variable "fifo_queue" {
  type    = bool
  default = false
}

variable "visibility_timeout_seconds" {
  description = "Should be >= the consumer's actual processing time, or messages get redelivered mid-processing."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  type    = number
  default = 345600 # 4 days
}

variable "enable_dlq" {
  description = "Create a dead-letter queue and wire it up via redrive_policy. Default true - a queue with no DLQ silently drops (or infinitely retries) poison messages."
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "How many times a message can be received before it's sent to the DLQ. Ignored if enable_dlq is false."
  type        = number
  default     = 5
}

variable "kms_master_key_id" {
  description = "Customer-managed KMS key for encryption at rest. Leave null to use SQS-managed SSE (SqsManagedSseEnabled) instead - either way, this module never leaves a queue unencrypted by default (unlike several queues found unencrypted in a real account audit this module is informed by)."
  type        = string
  default     = null
}
