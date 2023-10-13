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

  name = "${var.environment}-${var.database_name}"
}
