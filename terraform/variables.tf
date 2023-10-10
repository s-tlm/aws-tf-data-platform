#------------------------------------------------------------------------------
# Default region
#------------------------------------------------------------------------------

variable "default_region" {
  type        = string
  description = "The default AWS region"
  default     = "ap-southeast-2"
}

#------------------------------------------------------------------------------
# Choose which resources to create
#------------------------------------------------------------------------------


variable "create_rds" {
  type        = bool
  description = "Create RDS?"
  default     = false
}

variable "create_ec2" {
  type        = bool
  description = "Create EC2?"
  default     = false
}

variable "create_dms" {
  type        = bool
  description = "Create DMS?"
  default     = false
}


#------------------------------------------------------------------------------
# RDS config
#------------------------------------------------------------------------------

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

#------------------------------------------------------------------------------
# EC2 config
#------------------------------------------------------------------------------

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
