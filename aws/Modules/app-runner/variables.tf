variable "name_prefix" {
  description = "Prefix applied to the service name and its instance role."
  type        = string
}

variable "image_identifier" {
  description = "Full image URI (ECR or a public registry) App Runner deploys."
  type        = string
}

variable "port" {
  type    = number
  default = 8080
}

variable "cpu" {
  description = "App Runner CPU units, e.g. \"1 vCPU\"."
  type        = string
  default     = "1 vCPU"
}

variable "memory" {
  description = "App Runner memory, e.g. \"2 GB\"."
  type        = string
  default     = "2 GB"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "extra_instance_policy_arns" {
  description = "Additional managed policy ARNs for the instance role (what the running application code can call), beyond none by default. Same least-privilege philosophy as the lambda module's execution role - grant only what this specific service needs."
  type        = list(string)
  default     = []
}

variable "vpc_connector_subnet_ids" {
  description = "Private subnets to route App Runner's egress through. Leave empty (default) for public-internet-only egress; set this to let App Runner reach a private RDS/ElastiCache instance instead of needing it exposed publicly."
  type        = list(string)
  default     = []
}

variable "vpc_connector_security_group_ids" {
  type    = list(string)
  default = []
}

variable "autoscaling_min_size" {
  type    = number
  default = 1
}

variable "autoscaling_max_size" {
  description = "Lesson echoed from the capacity ASG modules: never leave this implicitly unbounded in prod - an explicit max caps a runaway scale-out instead of discovering the bill after the fact."
  type        = number
  default     = 4
}

variable "autoscaling_max_concurrency" {
  type    = number
  default = 100
}

variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}

variable "health_check_path" {
  type    = string
  default = "/health"
}
