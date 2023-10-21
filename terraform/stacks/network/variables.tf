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

variable "public_key" {
  type        = string
  sensitive = true
  description = "The directory of the SSH public key used to connect to the EC2 seed instance"
}

variable "activation_key" {
    type        = string
    sensitive   = true
    description = "The OpenVPN activation key"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type"
  default     = "t3.small"
}
