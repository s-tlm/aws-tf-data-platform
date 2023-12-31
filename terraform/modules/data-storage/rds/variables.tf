variable "create" {
  type        = bool
  description = "Create RDS instance?"
  default     = true
}

variable "project" {
  type        = string
  description = "The Terraform project name"
}

variable "seed" {
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

variable "instance_type" {
  type        = string
  description = "The EC2 seed instance type"
  default     = "t2.micro"
}

variable "instance_ami" {
  type        = string
  description = "The AMI of the EC2 seed instance"
  default     = "ami-0e812285fd54f7620"
}

variable "user_data_dir" {
  type        = string
  description = "The directory of the bash script used to initialise the EC2 seed instance"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
  default     = "fun"
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

variable "db_subnet_group_ids" {
  type        = list(string)
  description = "A list of subnet IDs to form the database subnet group"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to assign to the database and EC2 instances"
}

variable "public_key" {
  type        = string
  sensitive   = true
  description = "The directory of the SSH public key used to connect to the EC2 seed instance"
}

variable "instance_subnet" {
  type        = string
  description = "The subnet ID that will host the EC2 seed instance"
}

variable "default_tags" {
  type        = map(string)
  description = "Default resource tags"
  default     = {}
}
