terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.31"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.9.2"
    }
  }


  required_version = ">= 1.5.7"
}
