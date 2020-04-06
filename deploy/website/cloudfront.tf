resource "aws_cloudfront_origin_access_identity" "website_access_identity" {
  comment = "hallebarde-${var.env}"
}

resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_access_identity.cloudfront_access_identity_path
    }
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.website_access_identity.id
  }
  aliases = ["${var.env}.${var.route53_zone_name}"]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logs.id}.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = aws_cloudfront_origin_access_identity.website_access_identity.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "FR", "GB", "DE", "ES", "IT", "CH", "MA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    App = "hallebarde"
  }
}