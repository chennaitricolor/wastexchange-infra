# infra

Infra setup for waste-exchange project.

## Setup Notes

### terraform-remote-state

* Contains scripts for terraform remote state setup using S3 bucket and DynamoDB table.
* Only required for initial setup
* Setup using AWS admin credentials

### iam

* Conatains scripts for creating IAM roles used for managing AWS resources
* Setup using AWS admin credentials

### ec2

* Contains scripts for creating EC2 instance for the app
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes
* Use terraform workspaces to switch between different environments. Available workspaces:
    - staging

## rds

* Contains scripts for creating RDS (database) for the app
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes
* Use terraform workspaces to switch between different environments. Available workspaces:
    - staging
