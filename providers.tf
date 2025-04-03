provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}
