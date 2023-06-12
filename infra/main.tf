terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2.0"
    }
  }

  backend "s3" {
    bucket         	   = "aws-fastapi-lambda-tfstate" # create this bucket manually
    key              	   = "state/terraform.tfstate"
    region         	   = "eu-central-1"
    encrypt        	   = true
    dynamodb_table = "aws-fastapi-lambda-tf-lockid" # create this table manually
  }
}

provider "aws" {
  region = "eu-central-1"
}