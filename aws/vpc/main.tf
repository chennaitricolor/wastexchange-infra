locals {
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
    key            = "vpc/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
    role_arn       = "arn:aws:iam::736483828289:role/terraform-deploy"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Allow SSH from internet"
    Terraform   = true
  }
}
