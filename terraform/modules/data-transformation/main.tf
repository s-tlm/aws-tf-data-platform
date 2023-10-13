terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

resource "aws_glue_catalog_database" "this" {
  count = var.create ? 1 : 0

  name = "${var.project}-${var.environment}-${var.database_name}-db"
}

resource "aws_glue_crawler" "this" {
  count = var.create ? 1 : 0

  database_name = aws_glue_catalog_database.this[0].name
  name          = "${var.project}-${var.environment}-${var.database_name}-crawler"
  role          = "sample"

  s3_target {
    path = var.s3_target_path
  }
}
