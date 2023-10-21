terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

locals {
  num_public_subnets  = length(var.public_snet_config)
  num_private_subnets = length(var.private_snet_config)
  num_ingress_rules   = length(var.ingress_rules)
  num_egress_rules    = length(var.egress_rules)
  snets_with_nat      = [for each in var.public_snet_config : index(var.public_snet_config, each) if each.nat_gateway]
  num_snets_with_nat  = length(local.snets_with_nat)
}

resource "aws_vpc" "this" {
  count = var.create ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-vpc" }
  )
}

# Declare the data source
data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = var.create ? local.num_public_subnets : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_snet_config[count.index]["cidr_block"]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-pub-snet${count.index + 1}" }
  )
}

resource "aws_subnet" "private" {
  count = var.create ? local.num_private_subnets : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_snet_config[count.index]["cidr_block"]
  availability_zone = data.aws_availability_zones.this.names[count.index]

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-prv-snet${count.index + 1}" }
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-igw" }
  )
}

resource "aws_eip" "this" {
  count = var.create ? local.num_snets_with_nat : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create ? local.num_snets_with_nat : 0

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[local.snets_with_nat[count.index]].id
  depends_on    = [aws_internet_gateway.this[0]]
  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-nat${count.index + 1}" }
  )
}

resource "aws_route_table" "public" {
  count = var.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.additional_tags,
    { Name = "${var.project}-${var.environment}-pub-rtbl" }
  )
}

resource "aws_route" "public" {
  count = var.create ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table" "private" {
  count = var.create ? local.num_private_subnets : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(var.additional_tags,
    { Name = "${var.project}-${var.environment}-prv-rtbl${count.index + 1}" }
  )
}

resource "aws_route" "private" {
  count = var.create ? local.num_private_subnets : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.private_snet_config[count.index]["route_nat_to_subnet_index"]].id
}

resource "aws_route_table_association" "public" {
  count = var.create ? local.num_public_subnets : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create ? local.num_private_subnets : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_security_group" "default" {
  count = var.create ? 1 : 0

  name        = "${var.project}-${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.this[0].id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  count = var.create ? local.num_ingress_rules : 0

  security_group_id            = aws_security_group.default[0].id
  description                  = var.ingress_rules[count.index]["description"]
  cidr_ipv4                    = var.ingress_rules[count.index]["cidr_ipv4"]
  from_port                    = var.ingress_rules[count.index]["from_port"]
  to_port                      = var.ingress_rules[count.index]["to_port"]
  ip_protocol                  = var.ingress_rules[count.index]["ip_protocol"]
  referenced_security_group_id = var.ingress_rules[count.index]["self"] ? aws_security_group.default[0].id : null
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count = var.create ? local.num_egress_rules : 0

  security_group_id            = aws_security_group.default[0].id
  description                  = var.egress_rules[count.index]["description"]
  cidr_ipv4                    = var.egress_rules[count.index]["cidr_ipv4"]
  from_port                    = var.egress_rules[count.index]["from_port"]
  to_port                      = var.egress_rules[count.index]["to_port"]
  ip_protocol                  = var.egress_rules[count.index]["ip_protocol"]
  referenced_security_group_id = var.egress_rules[count.index]["self"] ? aws_security_group.default[0].id : null
}
