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
