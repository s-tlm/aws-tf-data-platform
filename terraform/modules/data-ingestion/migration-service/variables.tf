variable "create" {
  type        = bool
  description = "Create DMS instance?"
  default     = false
}

variable "target_s3_arn" {
  type        = string
  description = "The ARN of the target S3 bucket"
}

variable "environment" {
  type        = string
  description = "The AWS environment name"
  default     = "fun"
}

variable "source_endpoint" {
  type        = map(string)
  description = "The source endpoint configuration"
}

variable "target_s3_endpoint" {
  type        = map(string)
  description = "The target S3 endpoint configuration"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets forming the DMS subnet group"
}

variable "allocated_storage" {
  type        = number
  description = "The DMS replication instance allocated storage"
  default     = 10
}

variable "engine_version" {
  type        = string
  description = "The DMS replication instance engine version"
  default     = "3.5.1"
}

variable "replication_instance_public_access" {
  type        = bool
  description = "Whether the DMS replication instance is publicly accessible. Must be false if deployed in private subnet"
  default     = false
}

variable "replication_instance_class" {
  type        = string
  description = "The DMS replication instance class"
  default     = "dms.t2.micro"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to assign to DMS replication instance"
}

variable "table_mappings" {
  type        = string
  description = "The directory of the JSON containing the target table mapping"
}
