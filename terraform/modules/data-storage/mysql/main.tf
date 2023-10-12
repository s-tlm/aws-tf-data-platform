terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.7"
}

resource "aws_db_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.environment}-${var.engine}-snet-grp"
  description = "RDS ${var.engine} instance subnet group"
  subnet_ids  = var.db_subnet_group_ids
}

resource "aws_db_instance" "this" {
  count = var.create ? 1 : 0

  allocated_storage      = var.allocated_storage
  identifier             = "fun-db-dev"
  db_name                = "fundb"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.database_instance_class
  username               = var.master_username
  password               = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = var.vpc_security_group_ids

  skip_final_snapshot = true
  publicly_accessible = true
}

resource "aws_key_pair" "this" {
  count = var.create && var.seed ? 1 : 0

  key_name   = "${var.environment}-key"
  public_key = file(var.public_key)
}

resource "aws_instance" "this" {
  count = var.create && var.seed ? 1 : 0

  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this[0].key_name
  subnet_id              = var.instance_subnet
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = templatefile(var.user_data, {
    host     = try(aws_db_instance.this[0].address, ""),
    username = var.master_username,
    password = var.master_password
  })
  user_data_replace_on_change = true
  associate_public_ip_address = true

  tags = merge(
    var.additional_tags,
    { Name = "${var.environment}-${var.engine}-seed" }
  )
}
