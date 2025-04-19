variable "cloudflare_api_key" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "e2e_domain" {
  description = "Domain for E2E tests"
  type        = string
  default     = "e2e.app.awscommunity.mx"
}