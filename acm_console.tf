resource "aws_acm_certificate" "awscommunity_console_certificate" {
  domain_name       = "*.console.awscommunity.mx"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "awscommunity_apex_console_certificate" {
  domain_name       = "console.awscommunity.mx"
  validation_method = "DNS"
}

data "aws_route53_zone" "awscommunity_zone_console" {
  name         = "console.awscommunity.mx"
  private_zone = false
}

resource "aws_route53_record" "awscommunity_validation_record_console" {
  for_each = {
    for dvo in aws_acm_certificate.awscommunity_console_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.awscommunity_zone_console.zone_id
}

resource "aws_route53_record" "awscommunity_apex_validation_record_console" {
  for_each = {
    for dvo in aws_acm_certificate.awscommunity_apex_console_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.awscommunity_zone_console.zone_id
}

resource "aws_acm_certificate_validation" "awscommunity_console_certificate_validation_console" {
  certificate_arn         = aws_acm_certificate.awscommunity_console_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.awscommunity_validation_record_console : record.fqdn]
}

resource "aws_acm_certificate_validation" "awscommunity_apex_console_certificate_validation_console" {
  certificate_arn         = aws_acm_certificate.awscommunity_apex_console_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.awscommunity_apex_validation_record_console : record.fqdn]
}
