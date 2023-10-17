terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"

  backend "s3" {
    key = "network/terraform.tfstate"
  }
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.additional_tags
  }
}

#------------------------------------------------------------------------------
# Create VPC w. Public and Private Subnets
#------------------------------------------------------------------------------

module "main_vpc" {
  source = "../../modules/main-vpc"

  create = var.create

  vpc_cidr_block          = var.vpc_cidr_block
  public_snet_cidr_block  = var.public_snet_cidr_block
  private_snet_cidr_block = var.private_snet_cidr_block
  ingress_rules           = var.ingress_rules
  egress_rules            = var.egress_rules

  project         = var.project
  environment     = var.environment
  additional_tags = var.additional_tags
}

# Push outputs to SSM Parameter Store
resource "aws_ssm_parameter" "vpc_id" {
  name        = "/${var.project}/network/vpc_id"
  description = "The name of the main VPC"
  type        = "String"
  data_type   = "text"
  value       = module.main_vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "/${var.project}/network/public_subnet_ids"
  description = "A list of public subnet IDs in the VPC"
  type        = "StringList"
  data_type   = "text"
  value       = join(",", module.main_vpc.public_subnet_ids)
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "/${var.project}/network/private_subnet_ids"
  description = "A list of private subnet IDs in the VPC"
  type        = "StringList"
  data_type   = "text"
  value       = join(",", module.main_vpc.private_subnet_ids)
}

resource "aws_ssm_parameter" "default_vpc_security_group_id" {
  name        = "/${var.project}/network/default_vpc_security_group_id"
  description = "The default VPC security group ID"
  type        = "String"
  data_type   = "text"
  value       = module.main_vpc.default_vpc_security_group_id
}