variable "name_prefix" {
  type = string
}

variable "execution_role_name" {
  description = "Name of the existing ECS task execution role to attach the new secret-read policy to"
  type        = string
}

variable "backend_secret_name" {
  description = "Name of the existing Secrets Manager secret already created and populated for the backend"
  type        = string
}
