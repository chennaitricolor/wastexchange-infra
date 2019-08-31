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

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Allow HTTP from internet"
    Terraform   = true
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Allow HTTPS from internet"
    Terraform   = true
  }
}

resource "aws_security_group" "access_to_internet" {
  name        = "allow_internet"
  description = "Allow all outbound traffic"
  vpc_id = "${data.aws_vpc.default.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Allow access to internet"
    Terraform   = true
  }
}

resource "aws_security_group" "access_to_db" {
  name        = "access_to_db"
  description = "Allow inbound to database from VPC"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
  }

  tags = {
    Name        = "Allow inbound to database from VPC"
    Terraform   = true
  }
}
