terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.31"
    }
  }

  required_version = ">= 1.5.7"
}

# Configure Databricks Cross-Account Role
data "databricks_aws_assume_role_policy" "this" {
  external_id = var.account_id
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name               = "${var.project}-db-cross-account-${var.environment}"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
}

data "databricks_aws_crossaccount_policy" "this" {}

resource "aws_iam_role_policy" "this" {
  count = var.create ? 1 : 0

  name   = "${var.project}-db-policy-${var.environment}"
  role   = aws_iam_role.this[0].id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

resource "databricks_mws_credentials" "this" {
  count = var.create ? 1 : 0

  account_id       = var.account_id
  role_arn         = aws_iam_role.this[0].arn
  credentials_name = "${var.project}-db-creds-${var.environment}"

  depends_on = [aws_iam_role_policy.this[0]]
}

# Configure Databricks Network
resource "databricks_mws_networks" "this" {
  count = var.create ? 1 : 0

  account_id         = var.account_id
  network_name       = "${var.project}-db-network-${var.environment}"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
}

# Configure Databricks Storage
resource "aws_s3_bucket" "this" {
  count = var.create ? 1 : 0

  bucket        = "${var.project}-root-bucket-${var.environment}"
  force_destroy = true

  tags = merge(var.default_tags, {
    Name = "${var.project}-root-bucket-${var.environment}"
  })
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.this[0]]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create ? 1 : 0

  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "databricks_aws_bucket_policy" "this" {
  bucket = try(aws_s3_bucket.this[0].bucket, false)
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  policy = data.databricks_aws_bucket_policy.this.json

  depends_on = [aws_s3_bucket_public_access_block.this[0]]
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "databricks_mws_storage_configurations" "this" {
  count = var.create ? 1 : 0

  account_id                 = var.account_id
  bucket_name                = aws_s3_bucket.this[0].bucket
  storage_configuration_name = "${var.project}-db-storage-${var.environment}"
}

# Create the main workspace
resource "databricks_mws_workspaces" "this" {
  count = var.create ? 1 : 0

  account_id     = var.account_id
  workspace_name = "${var.project}-db-workspace-${var.environment}"
  aws_region     = "ap-southeast-2"

  credentials_id           = databricks_mws_credentials.this[0].credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this[0].storage_configuration_id
  network_id               = databricks_mws_networks.this[0].network_id
}
