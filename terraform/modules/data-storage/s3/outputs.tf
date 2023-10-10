output "bucket_arns" {
  description = "A list of S3 bucket ARNs"
  value       = try(aws_s3_bucket.this[*].arn, null)
}

output "bucket_ids" {
  description = "A list of S3 bucket IDs"
  value       = try(aws_s3_bucket.this[*].id, null)
}
