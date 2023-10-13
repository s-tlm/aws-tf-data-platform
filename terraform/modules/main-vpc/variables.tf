#------------------------------------------------------------------------------
# VPC config
#------------------------------------------------------------------------------

variable "create" {
  type        = bool
  description = "Create VPC?"
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

variable "vpc_cidr_block" {
  type        = string
  description = "Main VPC CIDR block"
}

variable "public_snet_cidr_block" {
  type        = list(string)
  description = "Public subnets CIDR block"
}


variable "private_snet_cidr_block" {
  type        = list(string)
  description = "Private subnets CIDR block"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}
