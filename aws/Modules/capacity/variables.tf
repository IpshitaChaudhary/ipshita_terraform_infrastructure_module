variable "name_prefix" {
  description = "Prefix for every resource this module creates (launch template, ASG, IAM role, capacity provider)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster to create. Instances register into it via ECS_CLUSTER in user data."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the container instances. Its architecture (x86_64 vs arm64) must match the images you deploy."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair for emergency SSH. Leave empty and use SSM Session Manager instead - no inbound port needed."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Private subnets the Auto Scaling group launches instances into. Spread them across at least two AZs."
  type        = list(string)
}

variable "container_instances_security_group_id" {
  description = "Security group attached to every container instance (the security module's container_instances_security_group_id output)."
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of container instances in the Auto Scaling group."
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of container instances the capacity provider may scale out to."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Initial number of container instances. Managed scaling adjusts it afterwards, so changes here after the first apply are mostly ignored."
  type        = number
}

variable "root_volume_size_gb" {
  description = "Size of each instance's encrypted gp3 root volume. 30 GB matches the ECS-optimized AMI default and leaves room for image layers."
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size_gb >= 30
    error_message = "root_volume_size_gb must be at least 30 - the ECS-optimized AMI snapshot itself is 30 GB."
  }
}
