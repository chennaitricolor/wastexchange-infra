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

### app

* Contains scripts for  creating EC2, RDS, Route53 etc for the application
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes
