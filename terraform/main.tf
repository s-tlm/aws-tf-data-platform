# Create MySQL database
# Use DMS to migrate sample data

#------------------------------------------------------------------------------
# Data
#------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_partition" "current" {}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------

locals {
  num_public_subnets  = length(var.public_snet_cidr_block)
  num_private_subnets = length(var.private_snet_cidr_block)
  # https://registry.terraform.io/modules/terraform-aws-modules/dms/aws/latest
  dns_suffix = data.aws_partition.current.dns_suffix
  region     = data.aws_region.current.name
}

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
# Create VPC w. Public Subnets
#------------------------------------------------------------------------------

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

# Declare the data source
data "aws_availability_zones" "this" {
  count = var.create_vpc ? 1 : 0

  state = "available"
}

resource "aws_subnet" "public" {
  count = var.create_vpc ? local.num_public_subnets : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_snet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.this[0].names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = var.create_vpc ? local.num_private_subnets : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.private_snet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.this[0].names[count.index]
}

resource "aws_internet_gateway" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "fun-igw"
  }
}

resource "aws_eip" "this" {
  count = var.create_vpc ? 1 : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc ? 1 : 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.private[0].id
  depends_on    = [aws_internet_gateway.this[0]]
  tags = {
    Name = "fun-nat"
  }
}

resource "aws_route_table" "public" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "fun-public-route-table"
  }
}

resource "aws_route_table" "private" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "fun-private-route-table"
  }
}

resource "aws_route" "public" {
  count = var.create_vpc ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route" "private" {
  count = var.create_vpc ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc ? local.num_public_subnets : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = var.create_vpc ? local.num_private_subnets : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_security_group" "default" {
  count = var.create_vpc ? 1 : 0

  name        = "fun-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  ingress {
    description = "Allow ingress to MySQL"
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

#------------------------------------------------------------------------------
# S3 Bucket(s)
#------------------------------------------------------------------------------

resource "aws_s3_bucket" "landing_zone" {
  count = var.create_landing_zone ? 1 : 0

  bucket        = "fun-landing-zone"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "landing_zone" {
  count = var.create_landing_zone ? 1 : 0

  bucket = aws_s3_bucket.landing_zone[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "landing_zone" {
  count = var.create_landing_zone ? 1 : 0

  bucket = aws_s3_bucket.landing_zone[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#------------------------------------------------------------------------------
# RDS MySQL Instance
#------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  count = var.create_vpc && var.create_rds ? 1 : 0

  name       = "fun-subnet-group"
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "mysql" {
  count = var.create_vpc && var.create_rds ? 1 : 0

  allocated_storage      = 20
  identifier             = "fun-db-dev"
  db_name                = "fundb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = [aws_security_group.default[0].id]
  publicly_accessible    = true
}

#------------------------------------------------------------------------------
# Load Demo Data to RDS with EC2 Instance
#------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  count = var.create_ec2 ? 1 : 0

  key_name   = "fun-key"
  public_key = file(var.public_key)
}

resource "aws_instance" "this" {
  count = var.create_ec2 ? 1 : 0

  ami                    = "ami-0e812285fd54f7620"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.this[0].key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.default[0].id]
  user_data = templatefile(var.user_data, {
    host     = aws_db_instance.mysql[0].address,
    username = var.username,
    password = var.password
  })
  user_data_replace_on_change = true
  associate_public_ip_address = true

  tags = {
    Name = "fun-ec2-dev"
  }
}

#------------------------------------------------------------------------------
# Migrate Data to S3 using DMS
#------------------------------------------------------------------------------

# TODO
# Create source and target DMS endpoints
# Create replication instance
# Create DMS instance and configure full-load task

data "aws_iam_policy_document" "role_assume" {
  count = var.create_dms ? 1 : 0

  statement {
    sid = "DMSAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      identifiers = [
        "dms.${local.dns_suffix}",
        "dms.${local.region}.${local.dns_suffix}",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "access_s3" {
  count = var.create_dms && var.create_landing_zone ? 1 : 0

  statement {
    sid = "S3Target"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging",
    ]
    resources = [
      aws_s3_bucket.landing_zone[0].arn,
      "${aws_s3_bucket.landing_zone[0].arn}/*"
    ]
  }
}

resource "aws_iam_role" "this" {
  count = var.create_dms ? 1 : 0

  name                  = "fun-dms-role"
  description           = "IAM service role for DMS"
  assume_role_policy    = data.aws_iam_policy_document.role_assume[0].json
  force_detach_policies = true
}

resource "aws_iam_policy" "access_s3" {
  count = var.create_dms ? 1 : 0

  name        = "fun-s3-access-role"
  description = "Policy to access DMS target S3 bucket"
  policy      = data.aws_iam_policy_document.access_s3[0].json
}


resource "aws_iam_policy_attachment" "role_s3_attach" {
  count = var.create_dms ? 1 : 0

  name       = "fun-dms-role-attachment"
  roles      = [aws_iam_role.this[0].name]
  policy_arn = aws_iam_policy.access_s3[0].arn
}

# resource "aws_dms_endpoint" "source" {

# }

# resource "aws_dms_endpoint" "target" {

# }

# resource "aws_dms_replication_instance" "name" {
#   
# }

# resource "aws_dms_replication_task" "this" {
