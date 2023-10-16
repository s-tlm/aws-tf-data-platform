terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

# S3 bucket
resource "aws_s3_bucket" "this" {
  count = var.create ? 1 : 0

  bucket = "${var.project}-${var.bucket_name}-${var.environment}"

  # Prevent accidental deletion of bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable S3 versioning
resource "aws_s3_bucket_versioning" "enabled" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt all data inside S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  count = var.create ? 1 : 0

  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Dynamo DB table
resource "aws_dynamodb_table" "terraform_locks" {
  count = var.create ? 1 : 0

  name                        = "${var.project}-${var.dynamodb_table_name}-${var.environment}"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "LockID"
  deletion_protection_enabled = true

  attribute {
    name = "LockID"
    type = "S"
  }
}
