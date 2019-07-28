provider "aws" {
  region  = "us-east-2"
  version = "~> 2.21"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "wex-terraform-state-1564297303"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
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
}
