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
  num_public_subnets  = length(var.public_snet_cidr_block)
  num_private_subnets = length(var.private_snet_cidr_block)
}

resource "aws_vpc" "this" {
  count = var.create ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment} VPC" }
  )
}

# Declare the data source
data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = var.create ? local.num_public_subnets : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_snet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment} Public Subnet ${count.index + 1}" }
  )
}

resource "aws_subnet" "private" {
  count = var.create ? local.num_private_subnets : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_snet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index]

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment} Private Subnet ${count.index + 1}" }
  )
}

resource "aws_internet_gateway" "this" {
  count = var.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment}-igw" }
  )
}

resource "aws_eip" "this" {
  count = var.create ? 1 : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.this[0]]
  tags = merge(
    var.additional_tags,
    { Name = "${var.environment}-nat" }
  )
}

resource "aws_route_table" "public" {
  count = var.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment}-pub-rtbl" }
  )
}

resource "aws_route" "public" {
  count = var.create ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table" "private" {
  count = var.create ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(var.additional_tags,
    { Name = "${var.environment}-prv-rtbl" }
  )
}

resource "aws_route" "private" {
  count = var.create ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = var.create ? local.num_public_subnets : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create ? local.num_private_subnets : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_security_group" "default" {
  count = var.create ? 1 : 0

  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  ingress {
    description = "Allow public ingress to MySQL RDS database"
    from_port   = "0"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH to EC2"
    from_port   = "0"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
