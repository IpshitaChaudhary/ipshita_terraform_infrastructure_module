variable "aws_region" {
  type = string
}

variable "family" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "memory_reservation" {
  description = "Soft memory limit (MiB) - the only memory value set anywhere in this task def"
  type        = number
}

variable "container_environment" {
  description = "Plain container environment variables - supply real values via your own terraform.tfvars, never commit them here"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "container_secrets" {
  description = "Container env vars sourced from Secrets Manager/SSM at task launch - each valueFrom is an ARN, never a plaintext value"
  type        = list(object({ name = string, valueFrom = string }))
  default     = []
}

variable "target_group_arn" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "enable_execute_command" {
  description = "Enables ECS Exec (shell into the running container for live diagnostics)"
  type        = bool
  default     = false
}

# --- Application Auto Scaling (task count) - see autoscaling.tf. Separate
# from, and upstream of, the EC2 Capacity Provider's own instance-count
# scaling in Modules/capacity - without this, desired_count never moves on
# its own, so a real traffic increase just degrades the existing tasks
# instead of adding more. ---

variable "cluster_name" {
  description = "Plain cluster name (not ARN) - required for the appautoscaling resource_id and the CloudWatch alarm dimension."
  type        = string
}

variable "autoscaling_min_capacity" {
  type    = number
  default = 2
}

variable "autoscaling_max_capacity" {
  type    = number
  default = 8
}
