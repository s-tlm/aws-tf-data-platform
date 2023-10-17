terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"

  backend "s3" {
    key = "data-storage/s3/terraform.tfstate"
  }
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.additional_tags
  }
}

#------------------------------------------------------------------------------
# Create Data Tiers
#------------------------------------------------------------------------------

module "data_tiers" {
  source = "../../../modules/data-storage/s3"

  create = var.create

  bucket_names = var.bucket_names
  project      = var.project
  environment  = var.environment
}

# Push outputs to SSM Parameter Store
resource "aws_ssm_parameter" "bucket_arns" {
  name        = "/${var.project}/storage/s3/bucket_arns"
  description = "A list of S3 bucket ARNs"
  type        = "StringList"
  data_type   = "text"
  value       = join(",", module.data_tiers.bucket_arns)
}