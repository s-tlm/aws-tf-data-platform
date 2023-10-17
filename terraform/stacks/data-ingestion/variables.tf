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

variable "source_endpoint" {
  type = object({
    endpoint_type = string
    engine_name   = string
    database_name = string
    server_name   = string
    port          = string
    username      = string
    password      = string
  })
  description = "The source endpoint configuration"
}

variable "target_s3_endpoint" {
  type = object({
    endpoint_type = string
    bucket_name   = string
    bucket_folder = string
    data_format   = string
  })
  description = "The target S3 endpoint configuration"
}

variable "table_mappings" {
  type        = string
  description = "The directory of the JSON containing the target table mapping"
}

variable "start_replication_task" {
  type        = bool
  description = "Whether to auto-start the replication task"
  default     = false
}