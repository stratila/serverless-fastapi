resource "aws_dynamodb_table" "example" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TestTableHashKey"
  name         = var.dynamodb_table_name

  attribute {
    name = "TestTableHashKey"
    type = "S"
  }

}
