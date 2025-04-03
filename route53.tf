resource "aws_route53_zone" "dev" {
  name = "app.awscommunity.mx"

  tags = {
    Environment = "app"
  }
}

data "cloudflare_zone" "main_zone" {
  zone_id = "914f895b638c5fd3731948303b6d0b26"
}

resource "cloudflare_dns_record" "ns" {
  for_each = toset(aws_route53_zone.dev.name_servers) # Convierte la lista en un conjunto para iterar
  zone_id = data.cloudflare_zone.main_zone.zone_id
  name    = "app.awscommunity.mx" # Nombre de la zona en Cloudflare
  type    = "NS"
  ttl     = 1 
  content = each.value
}

