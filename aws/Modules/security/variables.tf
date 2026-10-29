variable "name_prefix" {
  description = "Prefix for security group names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the security groups in."
  type        = string
}
