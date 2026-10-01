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
