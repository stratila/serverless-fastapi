terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2.0"
    }
  }

  backend "s3" {
    bucket         = "aws-fastapi-lambda-tfstate" # create this bucket manually
    key            = "state/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "aws-fastapi-lambda-tf-lockid" # create this table manually
  }
}

provider "aws" {
  region = "eu-central-1"
}
resource "random_pet" "fast_api_lambda_bucket_name" {
  prefix = "fastapi-lambda-bucket"
  length = 2
}

resource "aws_s3_bucket" "fast_api_lambda_bucket" {
  bucket        = random_pet.fast_api_lambda_bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "fast_api_lambda_bucket" {
  bucket = aws_s3_bucket.fast_api_lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "fast_api_lambda_exec" {
  name = "fast-api-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "fast_api_lambda_policy" {
  role       = aws_iam_role.fast_api_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "fast_api_lambda" {
  function_name = "fast-api-lambda"

  s3_bucket = aws_s3_bucket.fast_api_lambda_bucket.id
  s3_key    = aws_s3_object.fast_api_lambda.key

  runtime = "python3.10"
  handler = "app.main.handler"

  source_code_hash = filebase64sha256("../function.zip")

  role = aws_iam_role.fast_api_lambda_exec.arn

}


resource "aws_s3_object" "fast_api_lambda" {
  bucket = aws_s3_bucket.fast_api_lambda_bucket.id

  key    = "function.zip"
  source = "../function.zip"

  etag = filemd5("../function.zip")
}
