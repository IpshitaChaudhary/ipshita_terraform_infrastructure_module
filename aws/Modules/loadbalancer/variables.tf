variable "name_prefix" {
  description = "Prefix for the target group names and tags."
  type        = string
}

variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
}

variable "vpc_id" {
  description = "VPC the target groups live in."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnets the internet-facing ALB is placed in (at least two AZs)."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group attached to the ALB (security module output)."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate for the HTTPS listener. Must be in the same region as the ALB."
  type        = string
}

variable "https_listener_ssl_policy" {
  description = "TLS policy for the HTTPS listener. Prefer a TLS 1.3 policy."
  type        = string
}

variable "backend_container_port" {
  description = "Port the backend containers listen on (target group port)."
  type        = number
}

variable "frontend_container_port" {
  description = "Port the frontend containers listen on (target group port)."
  type        = number
}

variable "backend_host_header" {
  description = "Host header routed to the backend target group (e.g. \"api.example.com\")."
  type        = string
}

variable "frontend_host_header" {
  description = "Host header routed to the frontend target group (e.g. \"www.example.com\")."
  type        = string
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
  description = "Listener rule priority for the header-based internal test route. Must be unique on the listener."
  type        = number
  default     = 1
}

variable "internal_test_header_name" {
  description = "Custom HTTP header name real traffic never sends - not a secret in the security sense, just specific enough to never collide by accident."
  type        = string
  default     = "X-Internal-Test"
}

variable "internal_test_header_value" {
  description = "Secret header value that routes a request to the test route before DNS cutover. null disables the rule."
  type        = string
  default     = null
}
