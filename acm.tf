resource "aws_acm_certificate" "awscommunity_certificate" {
  domain_name       = "*.app.awscommunity.mx"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "awscommunity_apex_certificate" {
  domain_name       = "app.awscommunity.mx"
  validation_method = "DNS"
}

data "aws_route53_zone" "awscommunity_zone" {
  name         = "app.awscommunity.mx"
  private_zone = false
}

resource "aws_route53_record" "awscommunity_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.awscommunity_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.awscommunity_zone.zone_id
}

resource "aws_route53_record" "awscommunity_apex_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.awscommunity_apex_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.awscommunity_zone.zone_id
}

resource "aws_acm_certificate_validation" "awscommunity_certificate_validation" {
  certificate_arn         = aws_acm_certificate.awscommunity_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.awscommunity_validation_record : record.fqdn]
}

resource "aws_acm_certificate_validation" "awscommunity_apex_certificate_validation" {
  certificate_arn         = aws_acm_certificate.awscommunity_apex_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.awscommunity_apex_validation_record : record.fqdn]
}
