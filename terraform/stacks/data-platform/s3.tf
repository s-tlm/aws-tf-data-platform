module "data_tiers" {
  source = "../../modules/data-storage/s3"

  create = var.create_s3

  bucket_names = var.bucket_names
  project      = var.project
  environment  = var.environment
}
