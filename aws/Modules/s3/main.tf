resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_master_key_id == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_master_key_id
    }
  }
}

# Lesson from two real account audits: multiple S3 buckets were found with a
# wildcard Principal:"*" bucket policy AND zero Public Access Block settings
# - real customer data (receipts, support uploads) was downloadable by
# anyone with no authentication. Every bucket this module creates blocks all
# 4 public-access vectors by default; a caller who genuinely needs a public
# bucket (a CDN origin behind CloudFront should NOT need this at all - use
# OAI/OAC instead) has to explicitly override every one of these.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
