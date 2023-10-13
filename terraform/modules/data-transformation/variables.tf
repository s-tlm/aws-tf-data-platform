variable "create" {
  type        = bool
  description = "Create Glue services?"
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

variable "database_name" {
  type        = string
  description = "The database name"
}

variable "s3_target_path" {
  type        = string
  description = "The S3 storage location of the Parquet files to crawl"
}
