provider "aws" {
  region  = "us-east-2"
  version = "~> 2.21"
}

terraform {
  backend "s3" {
    bucket         = "wex-terraform-state-1564297303"
    key            = "terraform-remote-state/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "wex-terraform-state-1564297303"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Waste Exchange Terraform State"
    Environment = "All"
    Terraform   = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "wex-terraform-state-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Waste Exchange Terraform State Lock"
    Environment = "All"
    Terraform   = true
  }
}

