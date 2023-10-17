terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"

  backend "s3" {
    key = "data-storage/mysql/terraform.tfstate"
  }
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.additional_tags
  }
}

#------------------------------------------------------------------------------
# Create MySQL Database and Seed Data
#------------------------------------------------------------------------------

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/dintelliverse/network/public_subnet_ids"
}

data "aws_ssm_parameter" "default_vpc_security_group_id" {
  name = "/dintelliverse/network/default_vpc_security_group_id"
}

module "mysql" {
  source = "../../../modules/data-storage/rds"

  create = var.create
  seed   = var.seed

  engine                  = var.engine
  database_name           = var.database_name
  engine_version          = var.engine_version
  allocated_storage       = var.allocated_storage
  database_instance_class = var.database_instance_class
  storage_encrypted       = var.storage_encrypted
  instance_type           = var.instance_type
  instance_ami            = var.instance_ami
  master_username         = var.master_username
  master_password         = var.master_password
  public_key              = var.public_key
  publicly_accessible     = var.publicly_accessible
  db_subnet_group_ids     = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  vpc_security_group_ids  = split(",", data.aws_ssm_parameter.default_vpc_security_group_id.value)
  instance_subnet         = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  user_data               = var.user_data
  environment             = var.environment
  project                 = var.project

  additional_tags = var.additional_tags
}

resource "aws_ssm_parameter" "database_name" {
  name        = "/${var.project}/data_storage/mysql/database_name"
  description = "The name of the database"
  type        = "String"
  data_type   = "text"
  value       = module.mysql.database_name
}

resource "aws_ssm_parameter" "database_address" {
  name        = "/${var.project}/data_storage/mysql/database_address"
  description = "The connection address of the database"
  type        = "String"
  data_type   = "text"
  value       = module.mysql.database_address
}

resource "aws_ssm_parameter" "database_port" {
  name        = "/${var.project}/data_storage/mysql/database_port"
  description = "The connection port of the database"
  type        = "String"
  data_type   = "text"
  value       = module.mysql.database_port
}