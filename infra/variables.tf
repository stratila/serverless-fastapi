# Description: This file contains all the variables that are used in the project

variable "region" {
  type     = string
  nullable = false
}

variable "lambda_bucket_name" {
  type     = string
  nullable = false
}


variable "lambda_function_name" {
  type     = string
  nullable = false
}


variable "dynamodb_table_name" {
  type     = string
  nullable = false
}
