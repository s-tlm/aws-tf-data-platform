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

# Provision VPN server
# VARIABLES
# VPC ID
# Public Subnet ID
# EC2 Instance Type (default t3.small)

resource "aws_security_group" "vpn" {
  count = var.create ? 1 : 0 

  name        = "${var.project}-${var.environment}-vpn-instance-sg"
  description = "Security group to allow inbound/outbound to the OpenVPN server"
  vpc_id      = module.main_vpc.vpc_id
}

locals {
  ingress_rules = [
    {
      description = "Admin Web UI"
      ip_protocol = "tcp"
      from_port = "943"
      to_port = "943"
      cidr_ipv4 = "0.0.0.0/0"
    },
    {
      description = "Client Web UI"
      ip_protocol = "tcp"
      from_port = "443"
      to_port = "443"
      cidr_ipv4 = "0.0.0.0/0"
    },
    {
      description = "OpenVPN UDP"
      ip_protocol = "udp"
      from_port = "1194"
      to_port = "1194"
      cidr_ipv4 = "0.0.0.0/0"
    },
    {
      description = "SSH"
      ip_protocol = "tcp"
      from_port = "22"
      to_port = "22"
      cidr_ipv4 = "0.0.0.0/0"
    }
  ]
  num_ingress_rules = length(local.ingress_rules)
}

resource "aws_vpc_security_group_ingress_rule" "vpn" {
  count = var.create ? local.num_ingress_rules : 0

  security_group_id = aws_security_group.vpn[0].id
  description = local.ingress_rules[count.index]["description"]
  cidr_ipv4 = local.ingress_rules[count.index]["cidr_ipv4"]
  from_port = local.ingress_rules[count.index]["from_port"]
  to_port = local.ingress_rules[count.index]["to_port"]
  ip_protocol = local.ingress_rules[count.index]["ip_protocol"]
}

resource "aws_key_pair" "this" {
  count = var.create ? 1 : 0

  key_name   = "${var.project}-${var.environment}-vpn-instance-key"
  public_key = file(var.public_key)
}
# Deploy EC2 in public subnet
# Provision using Open VPN AMI

resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  ami                    = "ami-0df4b2961410d4cff" # Ubuntu Server 20.04
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this[0].key_name
  subnet_id              = module.main_vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  associate_public_ip_address = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-vpn" }
  )
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
