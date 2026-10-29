output "bucket_id" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the bucket, for IAM and bucket policies."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Feed this into the cloudfront module's static_assets_bucket_regional_domain_name input."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
