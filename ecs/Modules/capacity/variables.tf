variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type = list(string)
}

variable "container_instances_security_group_id" {
  type = string
}

variable "asg_min_size" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}
