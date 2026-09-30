variable "bucket_name" {
  description = "Globally-unique bucket name."
  type        = string
}

variable "versioning_enabled" {
  description = "Lesson from a real account audit: only 2 of 13 app-relevant buckets checked had versioning on - without it, an accidental delete/overwrite has no recovery path. Default true here; set false only for genuinely disposable content (build artifacts, caches)."
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "Customer-managed KMS key for default encryption. Leave null to use SSE-S3 (AES256) instead - either way, every bucket this module creates is encrypted by default."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Allow 'terraform destroy' to delete a non-empty bucket. Defaults false - a bucket holding real data should never be deletable by accident via a routine destroy."
  type        = bool
  default     = false
}

variable "allowed_principal_arns" {
  description = "ARNs (IAM roles/users, another AWS service principal, etc.) granted allowed_actions on this bucket. Leave empty (default) for no bucket policy at all - never defaults to a public/wildcard policy, unlike several real buckets found with Principal:\"*\" in two separate account audits."
  type        = list(string)
  default     = []
}

variable "allowed_actions" {
  description = "S3 actions granted to allowed_principal_arns. Defaults to read-only - widen explicitly (e.g. add s3:PutObject) only when a principal genuinely needs write access."
  type        = list(string)
  default     = ["s3:GetObject"]
}
