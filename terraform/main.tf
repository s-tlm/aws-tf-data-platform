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
  region = var.default_region
}

#------------------------------------------------------------------------------
# Create VPC w. Public and Private Subnets
#------------------------------------------------------------------------------

module "main_vpc" {
  source = "./modules/main-vpc/"

  create                  = true
  vpc_cidr_block          = "10.0.0.0/16"
  public_snet_cidr_block  = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  private_snet_cidr_block = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

module "data_tiers" {
  source = "./modules/data-storage/s3/"

  create       = true
  bucket_names = ["raw", "conformed", "curated"]
}

module "mysql" {
  source = "./modules/data-storage/mysql/"

  create                 = true
  master_username        = "masteruser"
  master_password        = "masterpassword"
  public_key             = "~/.ssh/id_rsa.pub"
  db_subnet_group_ids    = module.main_vpc.public_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  instance_subnet        = module.main_vpc.public_subnet_ids[0]
}

module "dms" {
  source = "./modules/data-ingestion/migration-service/"

  create        = true
  target_s3_arn = module.data_tiers.bucket_arns[0]
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
    bucket_name   = module.data_tiers.bucket_ids[0]
    bucket_folder = "rds-mysql"
    data_format   = "parquet"
  }
  subnet_ids             = module.main_vpc.private_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
}
