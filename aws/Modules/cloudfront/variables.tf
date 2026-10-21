variable "name_prefix" {
  description = "Prefix applied to every resource this module creates."
  type        = string
}

variable "static_assets_bucket_regional_domain_name" {
  description = "Regional domain name of the existing S3 bucket serving static assets (e.g. \"myapp-static.s3.us-east-1.amazonaws.com\") - never created by this module, see the s3 module for that."
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

variable "enable_html_cache" {
  description = "Cache the default (ALB/SSR) behavior with a short-TTL policy instead of CachingDisabled. Off by default - only turn it on once no_cache_path_patterns covers every personalized path, or one user's page can be served to another."
  type        = bool
  default     = false
}

variable "html_cache_ttl_seconds" {
  description = "Default and max TTL for cached HTML when enable_html_cache is true. The origin's own Cache-Control can still shorten it (min TTL is 0)."
  type        = number
  default     = 600
}

variable "html_cache_key_headers" {
  description = "Headers that change the rendered HTML (e.g. device-type headers for a responsive SSR app) and so must be part of the cache key."
  type        = list(string)
  default     = ["CloudFront-Is-Mobile-Viewer", "CloudFront-Is-Tablet-Viewer", "CloudFront-Is-Desktop-Viewer"]
}

variable "html_cache_key_cookies" {
  description = "Cookies that change the rendered HTML. Keep this short - every cookie added here splits the cache per distinct value."
  type        = list(string)
  default     = []
}

variable "html_cache_key_query_strings" {
  description = "Query strings that change the rendered HTML (e.g. a filter param). Everything else is stripped from the cache key."
  type        = list(string)
  default     = []
}

variable "no_cache_path_patterns" {
  description = "Path patterns that must never be cached (account, cart, checkout, auth, API calls, index.html, anything rendered per user). Routed to the ALB with CachingDisabled ahead of every other ordered behavior. Cross-check this against the app's own no-cache list AND any paths the current live distribution already excludes - a path missing here gets cached under the HTML tier and served to the next visitor."
  type        = list(string)
  default     = ["/api/*", "/account*", "/cart*", "/checkout*", "/login*", "/logout*", "/index.html"]
}
