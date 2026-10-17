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

  # Example wiring, for a small team with a couple of access tiers:
  #
  # human_access_groups = {
  #   "admin" = [
  #     "arn:aws:iam::aws:policy/AdministratorAccess",
  #   ]
  #   "power-user" = [
  #     "arn:aws:iam::aws:policy/PowerUserAccess",
  #   ]
  #   "read-only" = [
  #     "arn:aws:iam::aws:policy/ReadOnlyAccess",
  #   ]
  # }
  #
  # Add users to a group separately (aws_iam_user_group_membership, or by
  # hand) - this variable only owns the groups and their policies, not who's
  # in them, so rotating a person in/out never touches this module's state.
}
