#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------

output "vpc_id" {
  description = "The default VPC resource ID"
  value       = try(module.main_vpc.vpc_id, null)
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = try(module.main_vpc.public_subnet_ids, null)
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = try(module.main_vpc.private_subnet_ids, null)
}

output "default_security_group_id" {
  description = "The default VPC security group ID"
  value       = try(module.main_vpc.default_vpc_security_group_id, null)
}

#------------------------------------------------------------------------------
# S3 Data Tiers
#------------------------------------------------------------------------------

output "bucket_arns" {
  description = "List of S3 bucket ARNs"
  value       = try(module.data_tiers.bucket_arns, null)
}

#------------------------------------------------------------------------------
# RDS MySQL Source Database
#------------------------------------------------------------------------------

output "database_name" {
  description = "The name of the database"
  value       = try(module.mysql.database_name, null)
}

output "database_address" {
  description = "The connection address of the database"
  value       = try(module.mysql.database_address, null)
}

output "database_port" {
  description = "The connection port of the database"
  value       = try(module.mysql.database_port, null)
}
