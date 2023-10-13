terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

locals {
  num_buckets = length(var.bucket_names)
}

resource "aws_s3_bucket" "this" {
  count = var.create ? local.num_buckets : 0

  bucket        = "${var.project}-${var.bucket_names[count.index]}-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create ? local.num_buckets : 0

  bucket = aws_s3_bucket.this[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create ? local.num_buckets : 0

  bucket = aws_s3_bucket.this[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
