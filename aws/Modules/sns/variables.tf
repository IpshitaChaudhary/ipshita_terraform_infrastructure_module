variable "name_prefix" {
  description = "Prefix applied to the topic name this module creates."
  type        = string
}

variable "fifo_topic" {
  type    = bool
  default = false
}

variable "kms_master_key_id" {
  description = "Customer-managed KMS key for encryption at rest. Leave null to use the AWS-managed 'alias/aws/sns' key instead - either way, this module never leaves a topic unencrypted by default (a real account audit found several topics with no KMS key set at all)."
  type        = string
  default     = "alias/aws/sns"
}

variable "allowed_publisher_arns" {
  description = "ARNs (IAM roles/users, S3 bucket ARNs for event notifications, etc.) allowed to sns:Publish to this topic. Leave empty (default) for no topic policy at all - never defaults to a public/wildcard policy."
  type        = list(string)
  default     = []
}

variable "allowed_subscriber_arns" {
  description = "ARNs allowed to sns:Subscribe to this topic. Leave empty (default) for no subscribe policy - most topics only need allowed_publisher_arns."
  type        = list(string)
  default     = []
}
