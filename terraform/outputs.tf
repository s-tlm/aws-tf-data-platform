output "public_subnets" {
  description = "A list of public subnet IDs in the VPC"
  value       = module.main_vpc.public_subnet_ids
}

output "private_subnets" {
  description = "A list of private subnet IDs in the VPC"
  value       = module.main_vpc.private_subnet_ids
}

output "bucket_arns" {
  description = "A list of S3 bucket ARNs"
  value       = module.data_tiers.bucket_arns
}

output "bucket_ids" {
  description = "A list of S3 bucket IDs"
  value       = module.data_tiers.bucket_ids
}
