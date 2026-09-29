output "distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront's fixed global hosted zone ID - used as the alias target zone_id in a Route53 alias record."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "origin_access_identity_iam_arn" {
  description = "Feed this into the s3 module's bucket policy so the OAI can read the static assets bucket."
  value       = aws_cloudfront_origin_access_identity.this.iam_arn
}
