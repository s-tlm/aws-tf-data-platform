#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------

output "db_endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "landing_zone_arn" {
  description = "ARN of the landing zone S3 bucket"
  value       = aws_s3_bucket.landing_zone.arn
}

output "ec2_public_dns" {
  description = "Login DNS of the EC2 instance"
  value       = "ec2-user@${aws_instance.this.public_dns}"
}
