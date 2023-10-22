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

  name        = "${var.project}-${var.environment}-${var.engine}-snet-grp"
  description = "RDS ${var.engine} instance subnet group"
  subnet_ids  = var.db_subnet_group_ids
}

resource "aws_db_instance" "this" {
  count = var.create ? 1 : 0

  allocated_storage      = var.allocated_storage
  identifier             = "${var.project}-${var.environment}-${var.engine}-rds"
  db_name                = var.database_name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.database_instance_class
  username               = var.master_username
  password               = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = var.vpc_security_group_ids
  storage_encrypted      = var.storage_encrypted
  publicly_accessible    = var.publicly_accessible

  skip_final_snapshot = true
}

resource "aws_key_pair" "this" {
  count = var.create && var.seed ? 1 : 0

  key_name   = "${var.project}-${var.environment}-rds-seed-instance-key"
  public_key = file(var.public_key)
}

resource "aws_instance" "this" {
  count = var.create && var.seed ? 1 : 0

  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this[0].key_name
  subnet_id              = var.instance_subnet
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = templatefile(var.user_data_dir, {
    host     = try(aws_db_instance.this[0].address, ""),
    username = var.master_username,
    password = var.master_password
  })
  user_data_replace_on_change = true
  associate_public_ip_address = true

  tags = merge(
    var.default_tags,
    { Name = "${var.project}-${var.environment}-${var.engine}-seed" }
  )
}
