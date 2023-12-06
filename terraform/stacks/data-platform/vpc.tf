#------------------------------------------------------------------------------
# Create VPC w. Public and Private Subnets
#------------------------------------------------------------------------------

module "main_vpc" {
  source = "../../modules/main-vpc"

  create = var.create_network

  vpc_cidr_block      = var.vpc_cidr_block
  public_snet_config  = var.public_snet_config
  private_snet_config = var.private_snet_config
  ingress_rules       = var.ingress_rules
  egress_rules        = var.egress_rules

  project      = var.project
  environment  = var.environment
  default_tags = var.default_tags
}
