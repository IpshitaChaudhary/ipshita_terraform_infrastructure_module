variable "zone_name" {
  description = "Domain name of the existing hosted zone to look up (e.g. \"example.com\"). Never created by this module - a shared, customer-facing zone shouldn't be something a reusable module can recreate or delete by accident."
  type        = string
}

variable "private_zone" {
  description = "Whether the zone to look up is a private (VPC-associated) hosted zone rather than a public one."
  type        = bool
  default     = false
}

variable "record_name" {
  description = "Fully-qualified record name to create in the zone (e.g. \"app.example.com\")."
  type        = string
}

variable "record_type" {
  description = "DNS record type. \"A\" for an alias to an AWS resource (ALB, CloudFront, ...), \"CNAME\" otherwise."
  type        = string
  default     = "A"
}

variable "alias_target_dns_name" {
  description = "DNS name of the AWS resource this record points at (e.g. an ALB's dns_name or a CloudFront distribution's domain_name)."
  type        = string
}

variable "alias_target_zone_id" {
  description = "Hosted zone ID of the AWS resource this record points at (e.g. an ALB's zone_id or CloudFront's fixed zone ID)."
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether Route 53 should factor the alias target's health checks into DNS answers. Usually true for an ALB, false for CloudFront (which doesn't support it)."
  type        = bool
  default     = false
}
