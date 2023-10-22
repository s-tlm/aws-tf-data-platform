variable "create" {
  type        = bool
  description = "Create resource?"
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
  default     = "fun"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Main VPC CIDR block"
}

variable "public_snet_config" {
  type = list(object({
    cidr_block  = string
    nat_gateway = optional(bool, false)
  }))
  description = "Public subnets CIDR block and NAT configuration"
}

variable "private_snet_config" {
  type = list(object({
    cidr_block                = string
    route_nat_to_subnet_index = number
  }))
  description = "Private subnets CIDR block and NAT configuration"
}

variable "ingress_rules" {
  type = list(object({
    description = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    ip_protocol = string
    cidr_ipv4   = optional(string)
    self        = optional(bool, false)
  }))
  description = "A map of security group ingress rules to assign to the default security group"
  default     = []
}

variable "egress_rules" {
  type = list(object({
    description = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    ip_protocol = string
    cidr_ipv4   = optional(string)
    self        = optional(bool, false)
  }))
  description = "A map of security group egress rules to assign to the default security group"
  default     = []
}
