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

#------------------------------------------------------------------------------
# Create OpenVPN Server
#------------------------------------------------------------------------------

resource "aws_security_group" "vpn" {
  count = var.create_network ? 1 : 0

  name        = "${var.project}-${var.environment}-vpn-instance-sg"
  description = "Security group to allow inbound/outbound to the OpenVPN server"
  vpc_id      = module.main_vpc.vpc_id
}

locals {
  ingress_rules = [
    {
      description = "Admin Web UI"
      ip_protocol = "tcp"
      from_port   = "943"
      to_port     = "943"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "Client Web UI"
      ip_protocol = "tcp"
      from_port   = "443"
      to_port     = "443"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "OpenVPN UDP"
      ip_protocol = "udp"
      from_port   = "1194"
      to_port     = "1194"
      cidr_ipv4   = "0.0.0.0/0"
    },
    {
      description = "SSH"
      ip_protocol = "tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]
  num_ingress_rules = length(local.ingress_rules)
}

resource "aws_vpc_security_group_ingress_rule" "vpn" {
  count = var.create_network ? local.num_ingress_rules : 0

  security_group_id = aws_security_group.vpn[0].id
  description       = local.ingress_rules[count.index]["description"]
  cidr_ipv4         = local.ingress_rules[count.index]["cidr_ipv4"]
  from_port         = local.ingress_rules[count.index]["from_port"]
  to_port           = local.ingress_rules[count.index]["to_port"]
  ip_protocol       = local.ingress_rules[count.index]["ip_protocol"]
}

resource "aws_key_pair" "this" {
  count = var.create_network ? 1 : 0

  key_name   = "${var.project}-${var.environment}-vpn-instance-key"
  public_key = file(var.ssh_key)
}

resource "aws_instance" "this" {
  count = var.create_network ? 1 : 0

  ami           = "ami-0df4b2961410d4cff" # Ubuntu Server 20.04
  instance_type = var.vpn_instance_type
  key_name      = aws_key_pair.this[0].key_name
  subnet_id     = module.main_vpc.public_subnet_ids[0]
  vpc_security_group_ids = [
    module.main_vpc.default_vpc_security_group_id,
    aws_security_group.vpn[0].id
  ]
  user_data = file(var.vpn_user_data_dir)

  associate_public_ip_address = true
  user_data_replace_on_change = true

  tags = merge(
    var.default_tags,
    { Name = "${var.project}-${var.environment}-vpn-instance" }
  )
}
