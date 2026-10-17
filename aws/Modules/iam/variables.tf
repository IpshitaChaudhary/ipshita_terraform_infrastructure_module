variable "name_prefix" {
  description = "Prefix applied to every role name this module creates."
  type        = string
}

variable "extra_execution_policy_arns" {
  description = "Additional managed policy ARNs to attach to the task execution role, beyond the standard AmazonECSTaskExecutionRolePolicy (e.g. a custom Secrets Manager read policy)."
  type        = list(string)
  default     = []
}

variable "human_access_groups" {
  description = "Map of IAM group name to the list of managed policy ARNs to attach to it, for tiered human (console/CLI) access - e.g. { \"admin\" = [\"arn:aws:iam::aws:policy/AdministratorAccess\"], \"read-only\" = [\"arn:aws:iam::aws:policy/ReadOnlyAccess\"] }. Empty by default - this module makes no assumption about whether you want it managing human access groups at all."
  type        = map(list(string))
  default     = {}
}
