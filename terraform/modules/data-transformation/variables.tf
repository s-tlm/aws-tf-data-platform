variable "create" {
  type        = bool
  description = "Create Glue services?"
  default     = false
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
  default     = "fun"
}

variable "database_name" {
  type        = string
  description = "The Glue database name"
}
