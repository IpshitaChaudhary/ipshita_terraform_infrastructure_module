variable "aws_region" {
  description = "Region for the awslogs log driver."
  type        = string
}

variable "family" {
  description = "Task definition family. Also names the CloudWatch log group (/ecs/<family>)."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service. Also used in auto scaling resource IDs and policy names."
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster to run the service in (capacity module output)."
  type        = string
}

variable "capacity_provider_name" {
  description = "Capacity provider the service places tasks on (capacity module output)."
  type        = string
}

variable "execution_role_arn" {
  description = "Role ECS itself uses to pull the image and read secrets at task start."
  type        = string
}

variable "task_role_arn" {
  description = "Role the application code assumes at runtime for AWS API calls."
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition. The load balancer registers targets by this name."
  type        = string
}

variable "container_image" {
  description = "Initial image (repository URL + tag). Later deploys change it through CI/CD, which Terraform then ignores."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on, registered with the target group."
  type        = number
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
  description = "Target group the service registers its tasks with."
  type        = string
}

variable "desired_count" {
  description = "Initial number of tasks. Auto scaling owns the count after the first apply."
  type        = number
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
  description = "Lowest task count auto scaling may scale in to. Keep at 2+ for availability during deploys."
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Highest task count auto scaling may scale out to."
  type        = number
  default     = 8
}
