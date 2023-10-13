#------------------------------------------------------------------------------
# Provider
#------------------------------------------------------------------------------

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
  region = "ap-southeast-2"

  default_tags {
    tags = var.additional_tags
  }
}

#------------------------------------------------------------------------------
# Create VPC w. Public and Private Subnets
#------------------------------------------------------------------------------

module "main_vpc" {
  source = "./modules/main-vpc"

  create                  = true
  vpc_cidr_block          = "10.0.0.0/16"
  public_snet_cidr_block  = ["10.0.0.0/19", "10.0.32.0/19"]
  private_snet_cidr_block = ["10.0.96.0/19", "10.0.128.0/19"]
  project                 = var.project
  environment             = var.environment
  additional_tags         = var.additional_tags
  ingress_rules           = var.ingress_rules
  egress_rules            = var.egress_rules
}

#------------------------------------------------------------------------------
# Create Data Tiers
#------------------------------------------------------------------------------

module "data_tiers" {
  source = "./modules/data-storage/s3"

  create       = false
  bucket_names = ["bronze", "silver", "gold"]
  project      = var.project
  environment  = var.environment
}

#------------------------------------------------------------------------------
# Create MySQL Database and Seed Data
#------------------------------------------------------------------------------

module "mysql" {
  source = "./modules/data-storage/rds"

  create                 = false
  seed                   = false
  engine                 = "mysql"
  database_name          = "sakilaDb"
  engine_version         = "5.7"
  master_username        = "masteruser"
  master_password        = "masterpassword"
  public_key             = "~/.ssh/id_rsa.pub"
  db_subnet_group_ids    = module.main_vpc.public_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  instance_subnet        = try(module.main_vpc.public_subnet_ids[0], "")
  user_data              = "./modules/data-storage/rds/user-data/seed-database.sh"
  environment            = var.environment
  project                = var.project

  additional_tags = var.additional_tags
}

#------------------------------------------------------------------------------
# Create Migration Service
#------------------------------------------------------------------------------

module "dms" {
  source = "./modules/data-ingestion/migration-service"

  create        = false
  target_s3_arn = try(module.data_tiers.bucket_arns[0], "")
  source_endpoint = {
    endpoint_type = "source"
    engine_name   = "mysql"
    database_name = module.mysql.database_name
    server_name   = module.mysql.database_address
    username      = "masteruser"
    password      = "masterpassword"
    port          = module.mysql.database_port
  }
  target_s3_endpoint = {
    endpoint_type = "target"
    bucket_name   = try(module.data_tiers.bucket_ids[0], "")
    bucket_folder = "rds-mysql"
    data_format   = "parquet"
  }
  table_mappings         = "./config/dms/sakila-table-mapping.json"
  subnet_ids             = module.main_vpc.private_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  environment            = var.environment
  project                = var.project
  start_replication_task = false
}

#------------------------------------------------------------------------------
# Create Glue Data Catalog and Crawlers
#------------------------------------------------------------------------------

module "glue" {
  source = "./modules/data-transformation"

  create         = false
  database_name  = "sakila"
  s3_target_path = try("s3://${module.data_tiers.bucket_ids[0]}", "")
  environment    = var.environment
  project        = var.project
}
