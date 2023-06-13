resource "aws_dynamodb_table" "example" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TestTableHashKey"
  name         = "example-13281"

  attribute {
    name = "TestTableHashKey"
    type = "S"
  }

}
