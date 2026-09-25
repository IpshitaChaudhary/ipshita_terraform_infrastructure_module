variable "name_prefix" {
  description = "Prefix applied to every role name this module creates."
  type        = string
}

variable "extra_execution_policy_arns" {
  description = "Additional managed policy ARNs to attach to the task execution role, beyond the standard AmazonECSTaskExecutionRolePolicy (e.g. a custom Secrets Manager read policy)."
  type        = list(string)
  default     = []
}
