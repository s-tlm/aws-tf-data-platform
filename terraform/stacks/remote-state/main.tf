terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.additional_tags
  }
}

module "remote-state" {
  source = "../../modules/remote-state"

  create = var.create

  bucket_name         = var.bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  environment         = var.environment
  project             = var.project
}