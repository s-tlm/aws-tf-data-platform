terraform {
  # Move backend hcl here
  backend "s3" {
    region         = "ap-southeast-2"
    bucket         = "fun-tf-state-dev"
    dynamodb_table = "fun-tf-state-lock-dev"
    key            = "data-platform/terraform.tfstate"

    encrypt = true
  }
}

provider "aws" {
  region = var.default_region

  default_tags {
    tags = var.default_tags
  }
}

provider "databricks" {
  alias = "mws"

  host          = "https://accounts.cloud.databricks.com"
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
  account_id    = var.databricks_account_id
}
