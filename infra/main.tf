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
