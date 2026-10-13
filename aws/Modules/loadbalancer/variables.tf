variable "name_prefix" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "https_listener_ssl_policy" {
  type = string
}

variable "backend_container_port" {
  type = number
}

variable "frontend_container_port" {
  type = number
}

variable "backend_host_header" {
  type = string
}

variable "frontend_host_header" {
  type = string
}

# --- Optional attachment-only rule, see main.tf comment ---

variable "enable_internal_test_rule" {
  description = "Create the attachment-only listener rule. Off by default - only needed while a new target group has no real rule yet."
  type        = bool
  default     = false
}

variable "internal_test_target_group_arn" {
  description = "Target group the attachment-only rule forwards to."
  type        = string
  default     = null
}

variable "internal_test_rule_priority" {
  type    = number
  default = 1
}

variable "internal_test_header_name" {
  description = "Custom HTTP header name real traffic never sends - not a secret in the security sense, just specific enough to never collide by accident."
  type        = string
  default     = "X-Internal-Test"
}

variable "internal_test_header_value" {
  type    = string
  default = null
}
