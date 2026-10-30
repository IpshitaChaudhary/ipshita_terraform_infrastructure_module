variable "name_prefix" {
  description = "Prefix applied to the cluster name and every resource this module creates."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane (e.g. \"1.29\"). Leave null to let EKS pick its current default."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets the control plane's elastic network interfaces are attached to. Needs both public and private subnets across at least two AZs for a highly-available control plane."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the cluster's Kubernetes API endpoint is reachable from outside the VPC. Set to false and rely on endpoint_private_access for a fully private cluster."
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the cluster's Kubernetes API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "node_group_subnet_ids" {
  description = "Subnets the managed node group's EC2 instances launch into. Usually the private subnets, separate from the control plane's subnet_ids so nodes never need a public IP."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types the managed node group is allowed to use."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT capacity for the managed node group."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4
}

variable "secrets_kms_key_arn" {
  description = "ARN of an existing KMS key used to envelope-encrypt Kubernetes Secrets. Leave null to have the module create a dedicated key with rotation enabled. The key's policy must let the cluster role use it."
  type        = string
  default     = null
}

variable "secrets_kms_deletion_window_days" {
  description = "Waiting period (7-30 days) before the module-created Secrets key is actually deleted after a destroy. Ignored when secrets_kms_key_arn is set."
  type        = number
  default     = 30

  validation {
    condition     = var.secrets_kms_deletion_window_days >= 7 && var.secrets_kms_deletion_window_days <= 30
    error_message = "secrets_kms_deletion_window_days must be between 7 and 30."
  }
}
