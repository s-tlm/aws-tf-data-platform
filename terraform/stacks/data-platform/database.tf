module "mysql" {
  source = "../../modules/data-storage/rds"

  create = var.create_database
  seed   = var.seed_database

  engine                  = var.engine
  database_name           = var.database_name
  engine_version          = var.engine_version
  allocated_storage       = var.allocated_storage
  database_instance_class = var.database_instance_class
  storage_encrypted       = var.storage_encrypted
  instance_type           = var.seed_instance_type
  instance_ami            = var.instance_ami
  master_username         = var.master_username
  master_password         = var.master_password
  public_key              = var.ssh_key
  publicly_accessible     = var.publicly_accessible
  db_subnet_group_ids     = module.main_vpc.public_subnet_ids
  vpc_security_group_ids  = [module.main_vpc.default_vpc_security_group_id]
  instance_subnet         = module.main_vpc.public_subnet_ids[0]
  user_data_dir           = var.seed_user_data_dir

  environment  = var.environment
  project      = var.project
  default_tags = var.default_tags
}
