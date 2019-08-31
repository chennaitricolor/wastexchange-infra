data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  tf_state_bucket     = "wex-terraform-state-31082019"
  tf_state_lock_table = "wex-terraform-state-lock"
  account_number      = "${data.aws_caller_identity.current.account_id}"
}

provider "aws" {
  region  = "us-east-2"
  version = "~> 2.21"
}

terraform {
  backend "s3" {
    bucket         = "wex-terraform-state-31082019"
    key            = "iam/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
  }
}

