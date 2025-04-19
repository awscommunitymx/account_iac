resource "random_string" "playwright_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "playwright_reports" {
  bucket = "awscommunity-playwright-reports-${random_string.playwright_suffix.result}"

  tags = {
    Name        = "Playwright Reports"
    Environment = "app"
  }
}

resource "aws_s3_bucket_website_configuration" "playwright_reports_website" {
  bucket = aws_s3_bucket.playwright_reports.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "playwright_reports_public_access_block" {
  bucket = aws_s3_bucket.playwright_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_acm_certificate" "e2e" {
  domain_name       = var.e2e_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "Playwright Reports Certificate"
    Environment = "app"
  }
}

resource "aws_route53_record" "e2e_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.e2e.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.dev.zone_id
}

resource "aws_acm_certificate_validation" "e2e_validation" {
  certificate_arn         = aws_acm_certificate.e2e.arn
  validation_record_fqdns = [for record in aws_route53_record.e2e_validation_record : record.fqdn]
}

resource "aws_cloudfront_origin_access_control" "playwright_reports_oac" {
  name                              = "playwright-reports-oac"
  description                       = "OAC for Playwright Reports S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "playwright_reports_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "Distribution for Playwright E2E test reports"

  origin {
    domain_name              = aws_s3_bucket.playwright_reports.bucket_regional_domain_name
    origin_id                = "playwright-reports-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.playwright_reports_oac.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "playwright-reports-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = [var.e2e_domain]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.e2e.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.e2e_validation]
}

resource "aws_s3_bucket_policy" "playwright_reports_policy" {
  bucket = aws_s3_bucket.playwright_reports.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { "Service" : "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.playwright_reports.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.playwright_reports_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.playwright_reports_distribution]
}

resource "aws_route53_record" "playwright_reports_dns" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = var.e2e_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.playwright_reports_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.playwright_reports_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

output "playwright_reports_bucket" {
  value = aws_s3_bucket.playwright_reports.bucket
}