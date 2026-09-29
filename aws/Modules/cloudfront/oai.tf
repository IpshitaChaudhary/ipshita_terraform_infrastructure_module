# Created here (rather than expecting a caller to pass one in) so the
# module is self-contained - the s3 module's bucket policy just needs this
# resource's IAM ARN as an input, not the other way around.
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${var.name_prefix} static assets OAI"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.name_prefix}-security-headers"

  security_headers_config {
    strict_transport_security {
      override                   = true
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }
  }
}
