data "aws_iam_policy_document" "assume_role_from_user" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${local.account_number}:root",
      ]
    }
  }
}

resource "aws_iam_role" "terraform_deploy" {
  name               = "terraform-deploy"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_from_user.json}"
}

resource "aws_iam_role_policy" "manage_terraform_state" {
  name = "manage-terraform-state"
  role = "${aws_iam_role.terraform_deploy.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${local.tf_state_bucket}"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::${local.tf_state_bucket}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/${local.tf_state_lock_table}"
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": "ec2:*",
      "Condition": {
        "StringEquals": {
          "ec2:Region": "${data.aws_region.current.name}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "rds:*",
      "Resource": ["arn:aws:rds:${data.aws_region.current.name}:*:*"]
    },
    {
      "Effect": "Allow",
      "Action": ["rds:Describe*"],
      "Resource": ["*"]
    },
    {
      "Action": "iam:CreateServiceLinkedRole",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::*:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName":"rds.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}
