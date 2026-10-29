variable "name_prefix" {
  description = "Prefix applied to the service name and its instance role."
  type        = string
}

variable "image_identifier" {
  description = "Full image URI (ECR or a public registry) App Runner deploys."
  type        = string
}

variable "port" {
  description = "Port the container listens on. App Runner routes HTTPS traffic to it."
  type        = number
  default     = 8080
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
  description = "Plain (non-secret) environment variables for the container. Put secrets in Secrets Manager, not here."
  type        = map(string)
  default     = {}
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
  description = "Security groups for the VPC connector. Only used when the service needs to reach private resources in a VPC."
  type        = list(string)
  default     = []
}

variable "autoscaling_min_size" {
  description = "Minimum number of provisioned instances kept warm."
  type        = number
  default     = 1
}

variable "autoscaling_max_size" {
  description = "Lesson echoed from the capacity ASG modules: never leave this implicitly unbounded in prod - an explicit max caps a runaway scale-out instead of discovering the bill after the fact."
  type        = number
  default     = 4
}

variable "autoscaling_max_concurrency" {
  description = "Concurrent requests one instance handles before App Runner scales out."
  type        = number
  default     = 100
}

variable "health_check_protocol" {
  description = "Health check protocol: \"HTTP\" (checks health_check_path) or \"TCP\" (port open only)."
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Path probed when health_check_protocol is HTTP. Should return 200 without touching downstream dependencies."
  type        = string
  default     = "/health"
}
