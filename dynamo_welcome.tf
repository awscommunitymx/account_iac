# Dynamo table to track which phone numbers we have sent the welcome message to
resource "aws_dynamodb_table" "welcome_message" {
  name           = "welcome_message"
  billing_mode = "PAY_PER_REQUEST"
  hash_key       = "phone_number"
  attribute {
    name = "phone_number"
    type = "S"
  }
}