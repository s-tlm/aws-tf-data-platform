#------------------------------------------------------------------------------
# Project
#------------------------------------------------------------------------------

variable "default_region" {
  type    = string
  default = "ap-southeast-2"
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
}

#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------

variable "create_network" {
  type        = bool
  description = "Create VPC and VPN?"
  default     = true
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

variable "ssh_key" {
  type        = string
  sensitive   = true
  description = "The directory of the SSH public key used to connect to the EC2 instance"
}

variable "vpn_instance_type" {
  type        = string
  description = "The EC2 instance type"
  default     = "t3.micro"
}

variable "vpn_user_data_dir" {
  type        = string
  description = "The directory of the bash script used to initialise the EC2 VPN instance"
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------

variable "create_s3" {
  type        = bool
  description = "Create S3 buckets?"
  default     = true
}

variable "bucket_names" {
  type        = list(string)
  description = "A list of S3 buckets to create"
}

#------------------------------------------------------------------------------
# RDS MySQL Variables
#------------------------------------------------------------------------------

variable "create_database" {
  type        = bool
  description = "Create sample source database?"
  default     = true
}

variable "seed_database" {
  type        = bool
  description = "Seed database with sample data?"
  default     = true
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage for the RDS instance"
  default     = 20
}

variable "engine" {
  type        = string
  description = "The database engine"
}

variable "engine_version" {
  type        = string
  description = "The database engine version"
}

variable "database_name" {
  type        = string
  description = "The name of the RDS database"
}

variable "database_instance_class" {
  type        = string
  description = "The database instance compute class"
  default     = "db.t3.micro"
}

variable "storage_encrypted" {
  type        = bool
  description = "Whether the database is encrypted"
  default     = true
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the database is publicly accessible"
  default     = true
}

variable "seed_instance_type" {
  type        = string
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "instance_ami" {
  type        = string
  description = "The AMI of the EC2 seed instance"
  default     = "ami-0e812285fd54f7620"
}

variable "seed_user_data_dir" {
  type        = string
  description = "The directory of the bash script used to initialise the EC2 seed instance"
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

#------------------------------------------------------------------------------
# DMS
#------------------------------------------------------------------------------

variable "create_dms" {
  type        = bool
  description = "Create DMS?"
  default     = true
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

variable "table_mapping_dir" {
  type        = string
  description = "The directory of the JSON containing the target table mapping"
}

variable "start_replication_task" {
  type        = bool
  description = "Whether to auto-start the replication task"
  default     = false
}
