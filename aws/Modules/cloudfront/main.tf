# OAI, not OAC. OAC's per-request SigV4 signing to an S3 origin can produce
# intermittent, edge-location-specific errors on static asset loads that are
# invisible to curl/simple replication and only reproduce in real browsers at
# specific edges - OAI has no per-request signing step to fail. See the
# ecs module's README for the incident this is based on.
resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = var.price_class
  aliases         = var.aliases

  origin {
    origin_id   = "s3-static"
    domain_name = var.static_assets_bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  origin {
    origin_id   = "alb-dynamic"
    domain_name = var.alb_dns_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }

  # Dynamic/SSR pages -> the ALB. CachingDisabled + AllViewer so every
  # request reaches the origin fresh with full cookies/headers/query
  # strings - required for session/auth cookies to reach the backend.
  default_cache_behavior {
    target_origin_id           = "alb-dynamic"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    compress                   = true
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  # Static assets -> S3, CachingOptimized. Managed-CORS-S3Origin only
  # forwards what S3 actually needs (Origin/Access-Control-Request-*) -
  # forwarding unnecessary cookies/headers to an S3 origin is what caused
  # the intermittent 400s referenced in the OAI comment above.
  dynamic "ordered_cache_behavior" {
    for_each = var.static_asset_path_patterns
    content {
      path_pattern               = ordered_cache_behavior.value
      target_origin_id           = "s3-static"
      viewer_protocol_policy     = "redirect-to-https"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      compress                   = true
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-CORS-S3Origin
      response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = { Name = "${var.name_prefix}-cf" }
}
