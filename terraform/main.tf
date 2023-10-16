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

  create = true

  vpc_cidr_block          = var.vpc_cidr_block
  public_snet_cidr_block  = var.public_snet_cidr_block
  private_snet_cidr_block = var.private_snet_cidr_block
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

  create = true

  bucket_names = var.bucket_names
  project      = var.project
  environment  = var.environment
}

# Create folder
resource "aws_s3_object" "object" {
  bucket = module.data_tiers.bucket_ids[0]
  key    = "new_object_key"
}

#------------------------------------------------------------------------------
# Create MySQL Database and Seed Data
#------------------------------------------------------------------------------

module "mysql" {
  source = "./modules/data-storage/rds"

  create = true
  seed   = true

  engine                 = var.engine
  database_name          = var.database_name
  engine_version         = var.engine_version
  master_username        = var.master_username
  master_password        = var.master_password
  public_key             = var.public_key
  publicly_accessible    = var.publicly_accessible
  db_subnet_group_ids    = module.main_vpc.public_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  instance_subnet        = try(module.main_vpc.public_subnet_ids[0], "")
  user_data              = var.user_data
  environment            = var.environment
  project                = var.project

  additional_tags = var.additional_tags
}

#------------------------------------------------------------------------------
# Create Migration Service
#------------------------------------------------------------------------------

module "dms" {
  source = "./modules/data-ingestion/migration-service"

  create = false

  target_s3_arn = try(module.data_tiers.bucket_arns[0], "")
  source_endpoint = {
    endpoint_type = var.source_endpoint["endpoint_type"]
    engine_name   = var.source_endpoint["engine_name"]
    database_name = module.mysql.database_name
    server_name   = module.mysql.database_address
    username      = var.source_endpoint["username"]
    password      = var.source_endpoint["password"]
    port          = module.mysql.database_port
  }
  target_s3_endpoint = {
    endpoint_type = var.target_s3_endpoint["endpoint_type"]
    bucket_name   = try(module.data_tiers.bucket_ids[0], "")
    bucket_folder = var.target_s3_endpoint["bucket_folder"]
    data_format   = var.target_s3_endpoint["data_format"]
  }
  table_mappings         = var.table_mappings
  subnet_ids             = module.main_vpc.private_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  environment            = var.environment
  project                = var.project
  start_replication_task = var.start_replication_task
}

#------------------------------------------------------------------------------
# Create Glue Data Catalog and Crawlers
#------------------------------------------------------------------------------

module "glue" {
  source = "./modules/data-transformation"

  create = true

  database_name  = var.glue_database_name
  target_s3_arn  = try(module.data_tiers.bucket_arns[0], "")
  target_s3_path = try("s3://${module.data_tiers.bucket_ids[0]}/rds-mysql/${var.glue_database_name}", "")
  environment    = var.environment
  project        = var.project
}
