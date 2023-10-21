variable "default_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "create" {
  type        = bool
  description = "Create resource?"
  default     = true
}

variable "seed" {
  type        = bool
  description = "Seed database with sample data?"
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
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "instance_ami" {
  type        = string
  description = "The AMI of the EC2 seed instance"
  default     = "ami-0e812285fd54f7620"
}

variable "user_data" {
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

variable "public_key" {
  type        = string
  description = "The directory of the SSH public key used to connect to the EC2 seed instance"
}
