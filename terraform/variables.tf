variable "project" {
  type        = string
  description = "The Terraform project name"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
}

variable "ingress_rules" {
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = optional(string)
    self        = bool
  }))
  description = "A map of security group ingress rules to assign to the default security group"
  default = [
    {
      description = "Default"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      self        = true
    },
    {
      description = "Allow public ingress to MySQL RDS database"
      from_port   = 0
      to_port     = 3306
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      self        = false
    },
    {
      description = "Allow SSH to EC2"
      from_port   = 0
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      self        = false
    }
  ]
}

variable "egress_rules" {
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = optional(string)
    self        = bool
  }))
  description = "A map of security group egress rules to assign to the default security group"
  default = [
    {
      description = "Default"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      self        = false
    }
  ]
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}
