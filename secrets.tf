resource "aws_secretsmanager_secret" "eventbrite_api_key" {
  name        = "eventbrite/api_key"
  description = "Eventbrite API Key for integration purposes"
  
  tags = {
    Name        = "eventbrite-api-key"
    Environment = "production"
    CreatedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret" "algolia_app_id" {
  name        = "algolia/app_id"
  description = "Algolia Application ID for search functionality"
  
  tags = {
    Name        = "algolia-app-id"
    Environment = "production"
    CreatedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret" "algolia_api_key" {
  name        = "algolia/api_key"
  description = "Algolia API Key for search functionality"
  
  tags = {
    Name        = "algolia-api-key"
    Environment = "production"
    CreatedBy   = "terraform"
  }
}