output "public_subnet_ids" {
  description = "A list of public subnet IDs in the VPC"
  value       = try(aws_subnet.public[*].id, null)
}

output "private_subnet_ids" {
  description = "A list of private subnet IDs in the VPC"
  value       = try(aws_subnet.private[*].id, null)
}

output "default_vpc_security_group_id" {
  description = "The default VPC security group ID"
  value       = try(aws_security_group.default[0].id, null)
}
