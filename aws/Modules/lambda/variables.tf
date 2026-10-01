variable "name_prefix" {
  description = "Prefix applied to the function name and its IAM role."
  type        = string
}

variable "extra_execution_policy_arns" {
  description = "Additional managed policy ARNs to attach to the execution role, beyond the base CloudWatch Logs permissions. Defaults to none - a Lambda function should only get the specific AWS API access it actually needs (e.g. one scoped inline policy for a single DynamoDB table or S3 bucket), never a broad managed policy like AmazonS3FullAccess."
  type        = list(string)
  default     = []
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "filename" {
  description = "Local path to the deployment package zip. Mutually exclusive with s3_bucket/s3_key - set exactly one source."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket holding the deployment package zip. Mutually exclusive with filename."
  type        = string
  default     = null
}

variable "s3_key" {
  type    = string
  default = null
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "log_retention_days" {
  description = "Lesson baked in from day one: Lambda's own auto-created log group has no expiration at all. 30 days is a reasonable default - override per function if compliance needs longer."
  type        = number
  default     = 30
}

variable "enable_function_url" {
  description = "Create a Lambda function URL. Defaults false - most functions are invoked via an event source (ALB, API Gateway, SQS, etc.), not a direct public URL."
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Lesson from a real account audit: a function URL with AuthType NONE was found publicly invocable by anyone. Defaults to AWS_IAM - only set to NONE deliberately, for a genuine public webhook that does its own request validation."
  type        = string
  default     = "AWS_IAM"
}
