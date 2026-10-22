variable "name_prefix" {
  description = "Prefix applied to every resource name this module creates."
  type        = string
}

variable "manage_session_preferences" {
  description = "Create the account/region-wide Session Manager preferences document (SSM-SessionManagerRunShell). Only one can exist per account and region - set false if it's already managed elsewhere, or import it first."
  type        = bool
  default     = true
}

variable "run_as_default_user" {
  description = "Linux user for sessions started by an IAM identity that has no SSMSessionRunAs tag. Keeping the agent's own ssm-user here means turning Run As on changes nothing for untagged people."
  type        = string
  default     = "ssm-user"
}

variable "idle_session_timeout_minutes" {
  type    = number
  default = 20
}

variable "session_log_group_name" {
  description = "Optional CloudWatch Logs group that receives a full transcript of every session, outside the instance where nobody on it can delete it. Leave null to skip."
  type        = string
  default     = null
}

variable "access_tag_key" {
  description = "Instances must carry this tag (with access_tag_value) for the generated policy to allow starting a session on them. Scopes access to servers, instead of every instance in the account."
  type        = string
  default     = "SessionAccess"
}

variable "access_tag_value" {
  type    = string
  default = "true"
}

variable "named_users" {
  description = "Per-person Linux users to bake into instances via user data, as name => SSH public key. Use the same name as the person's SSMSessionRunAs tag so SSH and SSM land them as the same user."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for n in keys(var.named_users) : can(regex("^[a-z_][a-z0-9_-]{0,31}$", n))])
    error_message = "named_users keys must be valid Linux user names (lowercase, start with a letter or underscore, max 32 chars)."
  }
}

variable "session_recording_retention_days" {
  description = "Days to keep sudo session recordings (/var/log/sudo-io) before systemd-tmpfiles deletes them."
  type        = number
  default     = 90
}
