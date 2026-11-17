variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "aws_profile" {
  description = "Named AWS CLI profile to authenticate with. Leave null to use the default credential chain (env vars, SSO, instance role)."
  type        = string
  default     = null
}

variable "allowed_account_ids" {
  description = "AWS account IDs this stack may be applied to. The provider errors out on any other account, which catches a wrong profile before anything changes."
  type        = list(string)

  validation {
    condition     = length(var.allowed_account_ids) > 0
    error_message = "List at least one account ID - an empty list would allow every account."
  }
}

variable "environment" {
  description = "Environment name, applied as the Environment tag on every resource."
  type        = string
  default     = "prod"
}

variable "name_prefix" {
  description = "Prefix for every resource name in this stack."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "azs" {
  description = "Availability Zones to use. Use three for production."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 3
    error_message = "Production runs across at least three Availability Zones."
  }
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per AZ, same order as azs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "One private subnet CIDR per AZ, same order as azs."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "EKS control plane version. Pin it so an upgrade is a reviewed change, not a surprise."
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "Instance types for the ON_DEMAND node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_desired_size" {
  description = "Initial number of worker nodes."
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 9
}
