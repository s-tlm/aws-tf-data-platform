data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  # https://registry.terraform.io/modules/terraform-aws-modules/dms/aws/latest
  dns_suffix = data.aws_partition.current.dns_suffix
  region     = data.aws_region.current.name
}

data "aws_iam_policy_document" "role_assume" {
  count = var.create ? 1 : 0

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
  count = var.create ? 1 : 0

  statement {
    sid = "S3Target"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      var.target_s3_arn,
      "${var.target_s3_arn}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role" "access_s3" {
  count = var.create ? 1 : 0

  name               = "${var.environment}-dms-s3-role"
  description        = "IAM service role for DMS to access target S3 bucket"
  assume_role_policy = data.aws_iam_policy_document.role_assume[0].json

  force_detach_policies = true
}

resource "aws_iam_role" "dms_vpc" {
  count = var.create ? 1 : 0

  name                = "${var.environment}-dms-vpc-role"
  description         = "IAM service role for DMS to manage VPC"
  assume_role_policy  = data.aws_iam_policy_document.role_assume[0].json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"]

  force_detach_policies = true
}

resource "aws_iam_policy" "access_s3" {
  count = var.create ? 1 : 0

  name        = "${var.environment}-dms-s3-policy"
  description = "Policy to access DMS target S3 bucket"
  policy      = data.aws_iam_policy_document.access_s3[0].json
}

resource "aws_iam_role_policy_attachment" "role_s3_attach" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.access_s3[0].name
  policy_arn = aws_iam_policy.access_s3[0].arn
}

resource "aws_dms_endpoint" "this" {
  count = var.create ? 1 : 0

  endpoint_id   = "${var.environment}-dms-${var.source_endpoint["engine_name"]}-endpoint"
  endpoint_type = var.source_endpoint["endpoint_type"]
  engine_name   = var.source_endpoint["engine_name"]
  database_name = var.source_endpoint["database_name"]
  server_name   = var.source_endpoint["server_name"]
  username      = var.source_endpoint["username"]
  password      = var.source_endpoint["password"]
  port          = var.source_endpoint["port"]
}

resource "aws_dms_s3_endpoint" "this" {
  count = var.create ? 1 : 0

  endpoint_id             = "${var.environment}-dms-${var.target_s3_endpoint["bucket_name"]}-endpoint"
  endpoint_type           = var.target_s3_endpoint["endpoint_type"]
  bucket_name             = var.target_s3_endpoint["bucket_name"]
  bucket_folder           = var.target_s3_endpoint["bucket_folder"]
  data_format             = var.target_s3_endpoint["data_format"]
  service_access_role_arn = aws_iam_role.access_s3[0].arn
}

resource "aws_dms_replication_subnet_group" "this" {
  count = var.create ? 1 : 0

  replication_subnet_group_id          = "${var.environment}-dms-snet-grp"
  replication_subnet_group_description = "DMS subnet group"
  subnet_ids                           = var.subnet_ids

  # Requires service role with DMS VPC Management permissions
  depends_on = [aws_iam_role.dms_vpc]
}

resource "aws_dms_replication_instance" "this" {
  count = var.create ? 1 : 0

  replication_instance_id     = "${var.environment}-dms-replication-instance"
  allocated_storage           = var.allocated_storage
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  availability_zone           = data.aws_availability_zones.this.names[0]
  engine_version              = var.engine_version
  publicly_accessible         = var.replication_instance_public_access
  replication_instance_class  = var.replication_instance_class
  replication_subnet_group_id = aws_dms_replication_subnet_group.this[0].id
  vpc_security_group_ids      = var.vpc_security_group_ids
  multi_az                    = false

  depends_on = [aws_iam_role.dms_vpc]
}

resource "aws_dms_replication_task" "this" {
  count = var.create ? 1 : 0

  replication_task_id      = "${var.environment}-dms-replication-task"
  migration_type           = "full-load" # Can be full-load | cdc | full-load-and-cdc. Only full-load configured right noe
  replication_instance_arn = aws_dms_replication_instance.this[0].replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.this[0].endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.this[0].endpoint_arn
  table_mappings           = file(var.table_mappings)
}
