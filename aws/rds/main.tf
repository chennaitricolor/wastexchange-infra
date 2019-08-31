locals {
  environment      = "${terraform.workspace}"
  account_number   = "736483828289"
}

provider "aws" {
  region  = "us-east-2"
  version = "~> 2.21"

  assume_role {
    role_arn = "arn:aws:iam::${local.account_number}:role/terraform-deploy"
  }
}

terraform {
  backend "s3" {
    bucket         = "wex-terraform-state-31082019"
    key            = "rds/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
    role_arn       = "arn:aws:iam::736483828289:role/terraform-deploy"
  }
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!#"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "allow_from_vpc" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name        = "Allow inbound to database from VPC"
    Terraform   = true
  }
}

resource "aws_db_instance" "app" {
  identifier          = "wastexchange-${local.environment}"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "10.6"
  instance_class      = "db.t2.micro"
  name                = "wastexchange_${local.environment}"
  username            = "wastexchange_${local.environment}"
  password            = "${random_string.password.result}"
  skip_final_snapshot = true
  vpc_security_group_ids = [
    "${data.aws_security_group.allow_from_vpc.id}"
  ]

  tags = {
    Name        = "Waste Exchange App DB - ${local.environment}"
    Environment = "${local.environment}"
    Terraform   = true
  }
}
