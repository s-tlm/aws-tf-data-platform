# Create MySQL database
# Use DMS to migrate sample data

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

variable "vpc_cidr_block" {
  description = "Main VPC CIDR block"
  default     = "10.0.0.0/16"
  type        = string
}

variable "public_snet_cidr_block" {
  description = "Public subnets CIDR block"
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  type        = list(string)
}


variable "private_snet_cidr_block" {
  description = "Private subnets CIDR block"
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
  type        = list(string)
}

variable "username" {
  description = "Username for RDS DB"
  default     = "masteruser"
  type        = string
}

variable "password" {
  description = "Password for RDS DB"
  default     = "masterpassword"
  type        = string
}

variable "public_key" {
  description = "Path of public key used to SSH to EC2"
  default     = "~/.ssh/id_rsa.pub"
  type        = string
}

variable "user_data" {
  description = "Path to EC2 user data"
  default     = "./user-data/create-data.sh"
  type        = string
}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------

locals {
  num_public_subnets  = length(var.public_snet_cidr_block)
  num_private_subnets = length(var.private_snet_cidr_block)
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
  region  = "ap-southeast-2"
}

#------------------------------------------------------------------------------
# Create VPC w. Public Subnets
#------------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

# Declare the data source
data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = local.num_public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_snet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = local.num_private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_snet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "fun-igw"
  }
}

resource "aws_eip" "this" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.private[0].id
  depends_on    = [aws_internet_gateway.this]
  tags = {
    Name        = "fun-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "fun-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "fun-private-route-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = local.num_public_subnets

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = local.num_private_subnets

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "default" {
  name        = "fun-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.this.id

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
  bucket = "fun-landing-zone"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "landing_zone" {
  bucket = aws_s3_bucket.landing_zone.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "landing_zone" {
  bucket = aws_s3_bucket.landing_zone.id

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
  name       = "fun-subnet-group"
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  identifier             = "fun-db-dev"
  db_name                = "fundb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.default.id]
  publicly_accessible    = true
}

#------------------------------------------------------------------------------
# Load Demo Data to RDS with EC2 Instance
#------------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = "fun-key"
  public_key = file(var.public_key)
}

resource "aws_instance" "this" {
  ami                         = "ami-0e812285fd54f7620"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = aws_subnet.public[1].id
  vpc_security_group_ids      = [aws_security_group.default.id]
  user_data                   = templatefile(var.user_data, {
                                  host     = aws_db_instance.mysql.address, 
                                  username = var.username, 
                                  password = var.password
                                })
  user_data_replace_on_change = true
  
  tags = {
    Name = "fun-ec2-dev"
  }
}

#------------------------------------------------------------------------------
# Migrate Data to S3 using DMS
#------------------------------------------------------------------------------

# TODO
# Create policy to connect to landing zone
# Create source and target DMS endpoints
# Create DMS instance and configure full-load task


#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------

output "db_endpoint" {
  description = "The database endpoint"
  value = aws_db_instance.mysql.endpoint
}

output "landing_zone_arn" {
  description = "ARN of the landing zone S3 bucket"
  value = aws_s3_bucket.landing_zone.arn
}

output "ec2_public_dns" {
  description = "Login DNS of the EC2 instance"
  value       = "ec2-user@${aws_instance.this.public_dns}"
}
