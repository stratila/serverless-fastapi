region               = "us-east-1"
lambda_bucket_name   = "aws-fastapi-lambda-bucket-dev"
lambda_function_name = "aws-fastapi-lambda-dev"
dynamodb_table_name  = "dynamo-table-fastapi-lambda-dev"
endpoints = [
  {
    path   = "phone"
    method = "GET"
  },
  {
    path   = "phone"
    method = "POST"
  }
]
