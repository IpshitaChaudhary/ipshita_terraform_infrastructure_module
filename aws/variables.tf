# -----------------------------------------------------------------------------
# This module assumes an existing VPC, subnets, ACM certificate and IAM roles -
# it only reads them as plain input, it never imports or manages those
# resources itself. Everything it creates (ALB, security groups, capacity ASG,
# ECS cluster/services/task defs) is new and additive, so applying this module
# cannot touch anything else in your account.
# -----------------------------------------------------------------------------

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_profile" {
  description = "Named AWS CLI profile to use. Leave empty to fall back to the default provider chain (env vars, instance role, etc.)."
  type        = string
  default     = ""
}

# --- Existing network (referenced, not managed) ---

variable "vpc_id" {
  description = "Existing VPC ID the ALB and capacity instances will live in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Existing public subnets - used only by the new internet-facing ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Existing private subnets (routed via NAT) - the ECS EC2 capacity instances live here, no public IPs"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN used for the HTTPS listener"
  type        = string
}

variable "https_listener_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
}

# --- Existing IAM roles (referenced by name via data source, not managed) ---

variable "ecs_task_execution_role_name" {
  description = "Existing ECS task execution role name"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "ecs_task_role_name" {
  description = "Existing ECS task role name"
  type        = string
  default     = "ecsTaskRole"
}

# --- Naming ---

variable "name_prefix" {
  description = "Prefix for every resource name this module creates (security groups, IAM role, ASG, capacity provider, target groups, service names, cluster, ALB, task defs)"
  type        = string
  default     = "myapp-dev"
}

variable "ecs_cluster_name" {
  type    = string
  default = "myapp-dev-cluster"
}

variable "alb_name" {
  type    = string
  default = "myapp-dev-alb"
}

variable "backend_task_family" {
  type    = string
  default = "myapp-dev-backend"
}

variable "frontend_task_family" {
  type    = string
  default = "myapp-dev-frontend"
}

# --- EC2 capacity layer ---

variable "instance_type" {
  description = "Must be the same CPU architecture (x86_64/arm64) as the Docker images you deploy"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Existing EC2 key pair for SSH access to capacity instances (optional - SSM Session Manager works without it)"
  type        = string
  default     = ""
}

variable "capacity_asg_min_size" {
  type    = number
  default = 1
}

variable "capacity_asg_max_size" {
  type    = number
  default = 2
}

variable "capacity_asg_desired_capacity" {
  type    = number
  default = 1
}

# --- Existing ECR repositories (referenced by name, not managed) ---

variable "backend_repository_name" {
  description = "Existing ECR repository name for the backend image"
  type        = string
  default     = "myapp-backend"
}

variable "frontend_repository_name" {
  description = "Existing ECR repository name for the frontend image"
  type        = string
  default     = "myapp-frontend"
}

# --- Backend service ---

variable "backend_container_name" {
  type    = string
  default = "backend"
}

variable "backend_container_image" {
  description = "ECR (or any registry) image URI for the backend container"
  type        = string
}

variable "backend_container_port" {
  type    = number
  default = 3000
}

variable "backend_memory_reservation" {
  description = "Soft memory limit (MiB) for the backend container - no hard cpu/memory set anywhere in the task def"
  type        = number
  default     = 1024
}

variable "backend_desired_count" {
  type    = number
  default = 0
}

variable "backend_host_header" {
  description = "Host header the ALB listener rule matches to route to the backend"
  type        = string
  default     = "backend.dev.example.com"
}

variable "backend_secret_name" {
  description = "Name of an existing Secrets Manager secret (JSON key/value) already created and populated for the backend"
  type        = string
  default     = ""
}

variable "backend_secret_env_names" {
  description = "Keys inside the backend secret to expose as container env vars sourced from Secrets Manager (each becomes secrets[].valueFrom = <secret arn>:<key>::). Replace this illustrative list with your own secret's keys."
  type        = list(string)
  default = [
    "DATABASE_URL",
    "REDIS_PASSWORD",
    "JWT_SECRET",
    "PAYMENT_GATEWAY_API_KEY",
    "EMAIL_SERVICE_API_KEY",
    "THIRD_PARTY_INTEGRATION_TOKEN",
  ]
}

variable "backend_container_environment" {
  description = "Plain (non-secret) backend env vars - never put real secret values here, use backend_secret_env_names instead"
  type        = list(object({ name = string, value = string }))
  default     = []
}

# --- Frontend service ---

variable "frontend_container_name" {
  type    = string
  default = "frontend"
}

variable "frontend_container_image" {
  description = "ECR (or any registry) image URI for the frontend container"
  type        = string
}

variable "frontend_container_port" {
  type    = number
  default = 4200
}

variable "frontend_memory_reservation" {
  type    = number
  default = 768
}

variable "frontend_desired_count" {
  type    = number
  default = 0
}

variable "frontend_host_header" {
  description = "Host header the ALB listener rule matches to route to the frontend"
  type        = string
  default     = "frontend.dev.example.com"
}
