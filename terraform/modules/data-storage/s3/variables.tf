variable "create" {
  type        = bool
  description = "Create resource?"
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

variable "bucket_names" {
  type        = list(string)
  description = "A list of S3 buckets to create"
}
