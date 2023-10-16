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
  default = [
    {
      description = "Default"
      ip_protocol = "-1"
      self        = true
    },
    {
      description = "Allow public ingress to MySQL RDS database"
      from_port   = 0
      to_port     = 3306
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Allow SSH to EC2"
      from_port   = 0
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
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
  default = [
    {
      description = "Default"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
}

variable "bucket_names" {
  type        = list(string)
  description = "A list of S3 buckets to create"
}

variable "engine" {
  type        = string
  description = "The database engine"
}

variable "database_name" {
  type        = string
  description = "The name of the RDS database"
}

variable "engine_version" {
  type        = string
  description = "The database engine version"
}

variable "master_username" {
  type        = string
  sensitive   = true
  description = "The master username for the RDS instance"
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "The master password for the RDS instance"
}

variable "public_key" {
  type        = string
  description = "The directory of the SSH public key used to connect to the EC2 seed instance"
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the RDS instance is publicly accessible"
  default     = false
}

variable "user_data" {
  type        = string
  description = "The directory of the bash script used to initialise the EC2 seed instance"
}

variable "source_endpoint" {
  type        = map(string)
  description = "The source endpoint configuration"
}

variable "target_s3_endpoint" {
  type        = map(string)
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

variable "glue_database_name" {
  type        = string
  description = "The database name"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}
