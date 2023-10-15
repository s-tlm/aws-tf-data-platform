terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

data "aws_partition" "current" {}

locals {
  dns_suffix = data.aws_partition.current.dns_suffix
}

data "aws_iam_policy_document" "role_assume" {
  count = var.create ? 1 : 0

  statement {
    sid = "GlueAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = [
        "glue.${local.dns_suffix}"
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "access_s3" {
  count = var.create ? 1 : 0

  statement {
    sid = "S3Target"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${var.target_s3_arn}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "access_s3" {
  count = var.create ? 1 : 0

  name        = "${var.project}-${var.environment}-glue-s3-policy"
  description = "Policy for Glue to access target S3 bucket"
  policy      = data.aws_iam_policy_document.access_s3[0].json
}

resource "aws_iam_role" "access_s3" {
  count = var.create ? 1 : 0

  name                = "${var.project}-${var.environment}-glue-s3-role"
  description         = "IAM service role for Glue to access target S3 bucket"
  assume_role_policy  = data.aws_iam_policy_document.role_assume[0].json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"]

  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "role_s3_attach" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.access_s3[0].name
  policy_arn = aws_iam_policy.access_s3[0].arn
}

resource "aws_glue_catalog_database" "this" {
  count = var.create ? 1 : 0

  name = "${var.project}-${var.environment}-${var.database_name}-db"
}

resource "aws_glue_crawler" "this" {
  count = var.create ? 1 : 0

  database_name = aws_glue_catalog_database.this[0].name
  name          = "${var.project}-${var.environment}-${var.database_name}-crawler"
  role          = aws_iam_role.access_s3[0].arn

  s3_target {
    path = var.target_s3_path
  }
}
