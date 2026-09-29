variable "name_prefix" {
  description = "Prefix applied to every resource this module creates."
  type        = string
}

variable "static_assets_bucket_regional_domain_name" {
  description = "Regional domain name of the existing S3 bucket serving static assets (e.g. \"myapp-static.s3.us-east-1.amazonaws.com\") - never created by this module, see the s3 module for that."
  type        = string
}

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity path (e.g. aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path) used to grant this distribution read access to the static assets bucket. OAI, not OAC - see main.tf for why."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the existing ALB fronting the dynamic/SSR app - never created by this module."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate for the CloudFront alias domain(s) - must exist in us-east-1 regardless of where everything else runs, since CloudFront only accepts certs from that region."
  type        = string
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) for this distribution, e.g. [\"app.example.com\"]. Leave empty to stand up the distribution without claiming any real domain yet - useful for a parallel/standby build that's cut over later."
  type        = list(string)
  default     = []
}

variable "static_asset_path_patterns" {
  description = "Path patterns routed to the S3 origin instead of the ALB (static assets only)."
  type        = list(string)
  default     = ["*.js", "*.css", "*.svg", "*.png", "*.jpg", "*.ico", "*.woff", "*.woff2", "/assets/*", "/static/*"]
}

variable "price_class" {
  type    = string
  default = "PriceClass_200"
}
