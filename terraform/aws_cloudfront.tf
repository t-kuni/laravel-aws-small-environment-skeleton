locals {
  origin_domain = "app.XXXX.com"
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = local.origin_domain
    origin_id   = local.origin_domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["XXXX.com"]

  default_cache_behavior {
    allowed_methods  = ["POST", "HEAD", "PATCH", "DELETE", "PUT", "GET", "OPTIONS"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.origin_domain

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    // HTTPSに固定
    viewer_protocol_policy = "redirect-to-https"

    // キャッシュを無効化する
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "XXXX"
    ssl_support_method  = "sni-only"
  }
}
