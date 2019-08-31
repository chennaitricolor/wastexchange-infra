locals {
  environment      = "${terraform.workspace}"
  account_number   = "736483828289"
  ssh_user         = "ubuntu"
  private_key_path = "~/.ssh/wastexchange_rsa"
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
    key            = "ec2/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
    role_arn       = "arn:aws:iam::736483828289:role/terraform-deploy"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${local.environment}"
  public_key = "${file("files/deployer.pub")}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "allow_ssh" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name        = "Allow SSH from internet"
    Terraform   = true
  }
}

data "aws_security_group" "access_to_internet" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name        = "Allow access to internet"
    Terraform   = true
  }
}

data "aws_security_group" "allow_http" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name        = "Allow HTTP from internet"
    Terraform   = true
  }
}

data "aws_security_group" "allow_https" {
  vpc_id = "${data.aws_vpc.default.id}"

  tags = {
    Name        = "Allow HTTPS from internet"
    Terraform   = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [
    "${data.aws_security_group.allow_ssh.id}",
    "${data.aws_security_group.allow_http.id}",
    "${data.aws_security_group.allow_https.id}",
    "${data.aws_security_group.access_to_internet.id}"
  ]

  tags = {
    Name        = "Waste Exchange App - ${local.environment}"
    Environment = "${local.environment}"
    Terraform   = true
  }

  provisioner "remote-exec" {
    inline = ["echo 'Connected to the instance!'"]

    connection {
      type        = "ssh"
      host        = "${self.public_ip}"
      user        = "${local.ssh_user}"
      private_key = "${file("${local.private_key_path}")}"
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i '${self.public_ip},' -u ${local.ssh_user} --private-key ${local.private_key_path} ./ansible/playbook.yaml"
  }
}
