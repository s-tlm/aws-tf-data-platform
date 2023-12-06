variable "create" {
  type        = bool
  description = "Create Databricks workspace?"
  default     = true
}

variable "default_tags" {
  type        = map(string)
  description = "Default resource tags"
  default     = {}
}

variable "project" {
  type        = string
  description = "The Terraform project name"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
  default     = "dev"
}

variable "account_id" {
  type        = string
  description = "The Databricks Account ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group IDs"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}
