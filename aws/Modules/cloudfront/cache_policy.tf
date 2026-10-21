# Optional middle tier between "never cache" (CachingDisabled) and "cache
# for a long time" (CachingOptimized, static assets): a short TTL for
# server-rendered HTML that's the same for every visitor. Only the headers,
# cookies and query strings that actually change the rendered page go into
# the cache key - everything else would just fragment the cache. Pages that
# vary per user must be excluded via var.no_cache_path_patterns, which
# matters far more than the TTL itself once this tier is turned on.
resource "aws_cloudfront_cache_policy" "html" {
  count = var.enable_html_cache ? 1 : 0

  name        = "${var.name_prefix}-html-short-ttl"
  comment     = "Short-TTL cache for anonymous, non-personalized SSR pages"
  min_ttl     = 0
  default_ttl = var.html_cache_ttl_seconds
  max_ttl     = var.html_cache_ttl_seconds

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    headers_config {
      header_behavior = length(var.html_cache_key_headers) > 0 ? "whitelist" : "none"
      dynamic "headers" {
        for_each = length(var.html_cache_key_headers) > 0 ? [1] : []
        content {
          items = var.html_cache_key_headers
        }
      }
    }

    cookies_config {
      cookie_behavior = length(var.html_cache_key_cookies) > 0 ? "whitelist" : "none"
      dynamic "cookies" {
        for_each = length(var.html_cache_key_cookies) > 0 ? [1] : []
        content {
          items = var.html_cache_key_cookies
        }
      }
    }

    query_strings_config {
      query_string_behavior = length(var.html_cache_key_query_strings) > 0 ? "whitelist" : "none"
      dynamic "query_strings" {
        for_each = length(var.html_cache_key_query_strings) > 0 ? [1] : []
        content {
          items = var.html_cache_key_query_strings
        }
      }
    }
  }
}
