resource "aws_secretsmanager_secret" "eventbrite_api_key" {
  name        = "eventbrite/api_key"
  description = "Eventbrite API Key for integration purposes"
  
  tags = {
    Name        = "eventbrite-api-key"
    Environment = "production"
    CreatedBy   = "terraform"
  }
}