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
