variable "name_prefix" {
  description = "Prefix applied to every resource name/tag this module creates."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones to spread subnets across. One public + one private subnet is created per AZ listed here."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR block per public subnet, in the same order as var.azs."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR block per private subnet, in the same order as var.azs."
  type        = list(string)
}
