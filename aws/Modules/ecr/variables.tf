variable "backend_repository_name" {
  description = "Name of the existing ECR repository that holds backend images (looked up, not created)."
  type        = string
}

variable "frontend_repository_name" {
  description = "Name of the existing ECR repository that holds frontend images (looked up, not created)."
  type        = string
}
