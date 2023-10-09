#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------

output "db_endpoint" {
  description = "The database endpoint"
  value       = try(aws_db_instance.mysql[0].endpoint, null)
}

output "landing_zone_arn" {
  description = "ARN of the landing zone S3 bucket"
  value       = try(aws_s3_bucket.landing_zone[0].arn, null)
}

output "ec2_public_dns" {
  description = "Login DNS of the EC2 instance"
  value       = try("ec2-user@${aws_instance.this[0].public_dns}", null)
}

output "dms_replication_task_status" {
  description = "The status of the DMS replication task"
  value       = try(aws_dms_replication_task.this[0].status, null)
}
