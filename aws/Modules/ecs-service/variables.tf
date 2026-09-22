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
