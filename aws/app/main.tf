locals {
  environment      = "${terraform.workspace}"
  account_number   = "719386365084"
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
    bucket         = "wex-terraform-state-1564297303"
    key            = "ec2/terraform.tfstate" # this should be unique across terraform project directories
    region         = "us-east-2"
    dynamodb_table = "wex-terraform-state-lock"
    role_arn       = "arn:aws:iam::719386365084:role/terraform-deploy"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("files/deployer.pub")}"
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