#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

variable "vpc_cidr_block" {
  type        = string
  description = "Main VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_snet_cidr_block" {
  type        = list(string)
  description = "Public subnets CIDR block"
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}


variable "private_snet_cidr_block" {
  type        = list(string)
  description = "Private subnets CIDR block"
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "username" {
  type        = string
  description = "Username for RDS DB"
  default     = "masteruser"
}

variable "password" {
  type        = string
  description = "Password for RDS DB"
  default     = "masterpassword"
}

variable "public_key" {
  type        = string
  description = "Path of public key used to SSH to EC2"
  default     = "~/.ssh/id_rsa.pub"
}

variable "user_data" {
  type        = string
  description = "Path to EC2 user data"
  default     = "./user-data/create-data.sh"
}
