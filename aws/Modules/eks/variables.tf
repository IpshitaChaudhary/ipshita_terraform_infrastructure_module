variable "name_prefix" {
  description = "Prefix applied to the cluster name and every resource this module creates."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane (e.g. \"1.29\"). Leave null to let EKS pick its current default."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "Existing VPC to run the cluster in (e.g. the vpc_id output of the vpc module)."
  type        = string
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
