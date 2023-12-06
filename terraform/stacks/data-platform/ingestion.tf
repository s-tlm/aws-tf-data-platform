module "dms" {
  source = "../../modules/data-ingestion/dms"

  create = var.create_dms

  source_endpoint = {
    endpoint_type = var.source_endpoint["endpoint_type"]
    engine_name   = var.source_endpoint["engine_name"]
    database_name = var.source_endpoint["database_name"]
    server_name   = var.source_endpoint["server_name"]
    port          = var.source_endpoint["port"]
    username      = var.source_endpoint["username"]
    password      = var.source_endpoint["password"]
  }
  target_s3_endpoint = {
    endpoint_type = var.target_s3_endpoint["endpoint_type"]
    bucket_name   = var.target_s3_endpoint["bucket_name"]
    bucket_folder = var.target_s3_endpoint["bucket_folder"]
    data_format   = var.target_s3_endpoint["data_format"]
  }
  target_s3_arn          = try(module.data_tiers.bucket_arns[0], false)
  table_mappings         = var.table_mapping_dir
  subnet_ids             = module.main_vpc.private_subnet_ids
  vpc_security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  start_replication_task = var.start_replication_task

  environment = var.environment
  project     = var.project
}

