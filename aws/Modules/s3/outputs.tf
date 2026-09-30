output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Feed this into the cloudfront module's static_assets_bucket_regional_domain_name input."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
