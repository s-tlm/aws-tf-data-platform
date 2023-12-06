#------------------------------------------------------------------------------
# Create Databricks
#------------------------------------------------------------------------------

module "databricks_ws" {
  source = "../../modules/data-transformation/databricks/workspace-create"
  providers = {
    databricks = databricks.mws
  }

  create = var.create_databricks

  account_id         = var.databricks_account_id
  security_group_ids = [module.main_vpc.default_vpc_security_group_id]
  subnet_ids         = module.main_vpc.private_subnet_ids # must be private
  vpc_id             = module.main_vpc.vpc_id

  project      = var.project
  environment  = var.environment
  default_tags = var.default_tags
}
