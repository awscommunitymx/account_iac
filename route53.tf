resource "aws_route53_zone" "dev" {
  name = "app.awscommunity.mx"

  tags = {
    Environment = "app"
  }
}

data "cloudflare_zone" "main_zone" {
  zone_id = ""
}


# Outputs
output "app_zone_id" {
  description = "ID de la zona alojada de Route53"
  value       = aws_route53_zone.dev.zone_id
}

output "app_zone_name_servers" {
  description = "Servidores de nombres asignados a la zona alojada"
  value       = aws_route53_zone.dev.name_servers
}
# 3. Update Cloudflare NS Records
resource "cloudflare_dns_record" "ns" {
  for_each = toset(aws_route53_zone.dev.name_servers) # Convierte la lista en un conjunto para iterar
  zone_id = data.cloudflare_zone.main_zone.zone_id
  name    = "app.awscommunity.mx" # Nombre de la zona en Cloudflare
  type    = "NS"
  ttl     = 1 
  content = each.value
}

