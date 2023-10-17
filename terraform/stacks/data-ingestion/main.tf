terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"

  backend "s3" {
    key = "data-ingestion/terraform.tfstate"
  }
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.additional_tags
  }
}

#------------------------------------------------------------------------------
# Create Migration Service
#------------------------------------------------------------------------------

data "aws_ssm_parameter" "bucket_arns" {
  name = "/dintelliverse/storage/s3/bucket_arns"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/dintelliverse/network/private_subnet_ids"
}

data "aws_ssm_parameter" "default_vpc_security_group_id" {
  name = "/dintelliverse/network/default_vpc_security_group_id"
}

module "dms" {
  source = "../../modules/data-ingestion/dms"

  create = var.create

  source_endpoint = {
    endpoint_type = var.source_endpoint["endpoint_type"]
    engine_name   = var.source_endpoint["engine_name"]
    database_name = var.source_endpoint["database_name"]
    server_name   = var.source_endpoint["server_name"]
    port          = var.source_endpoint["port"]
    username      = var.source_endpoint["username"]
    password      = var.source_endpoint["password"]
  }
  target_s3_endpoint = {
    endpoint_type = var.target_s3_endpoint["endpoint_type"]
    bucket_name   = var.target_s3_endpoint["bucket_name"]
    bucket_folder = var.target_s3_endpoint["bucket_folder"]
    data_format   = var.target_s3_endpoint["data_format"]
  }
  target_s3_arn          = split(",", data.aws_ssm_parameter.bucket_arns.value)[0]
  table_mappings         = var.table_mappings
  subnet_ids             = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  vpc_security_group_ids = split(",", data.aws_ssm_parameter.default_vpc_security_group_id.value)
  start_replication_task = var.start_replication_task

  environment = var.environment
  project     = var.project
}