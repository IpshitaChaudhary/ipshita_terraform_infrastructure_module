variable "name_prefix" {
  description = "Prefix applied to the function name and its IAM role."
  type        = string
}

variable "extra_execution_policy_arns" {
  description = "Additional managed policy ARNs to attach to the execution role, beyond the base CloudWatch Logs permissions. Defaults to none - a Lambda function should only get the specific AWS API access it actually needs (e.g. one scoped inline policy for a single DynamoDB table or S3 bucket), never a broad managed policy like AmazonS3FullAccess."
  type        = list(string)
  default     = []
}
