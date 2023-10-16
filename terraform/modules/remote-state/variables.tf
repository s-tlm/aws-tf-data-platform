variable "create" {
  type        = bool
  description = "Create resources to manage remote state?"
  default     = false
}

variable "project" {
  type        = string
  description = "The Terraform project name"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
  default     = "fun"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
}
