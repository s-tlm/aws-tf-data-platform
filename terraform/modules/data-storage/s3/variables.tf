variable "create" {
  type        = bool
  description = "Create S3 buckets?"
  default     = false
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
