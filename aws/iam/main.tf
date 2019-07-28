provider "aws" {
  region  = "us-east-2"
  version = "~> 2.21"
}

terraform {
  backend "s3" {
    bucket         = "wex-terraform-state-1564297303"
    key            = "iam-roles/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
  }
}

