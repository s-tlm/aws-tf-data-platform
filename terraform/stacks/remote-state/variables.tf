variable "default_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "create" {
  type        = bool
  description = "Create resource?"
  default     = true
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}

variable "project" {
  type        = string
  description = "The Terraform project name"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
}