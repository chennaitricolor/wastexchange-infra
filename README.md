# wastexchange-infra

Infra setup for waste-exchange project.

## Setup Notes

### terraform-remote-state

* Contains scripts for terraform remote state setup using S3 bucket and DynamoDB table.
* Only required for initial setup
* Setup using AWS admin credentials

```
terraform init
terraform plan
terraform apply
```

### iam

* Conatains scripts for creating IAM roles used for managing AWS resources
* Setup using AWS admin credentials

```
terraform init
terraform plan
terraform apply
```

### ec2

* Contains scripts for creating EC2 instance for the app
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes
* Use terraform workspaces to switch between different environments. Available workspaces:
    - staging

```
terraform init

# to create workspace
terraform workspace new <staging|production>

# to switch workspace
terraform workspace select <staging|production>

terraform plan
terraform apply
```

## rds

* Contains scripts for creating RDS (database) for the app
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes
* Use terraform workspaces to switch between different environments. Available workspaces:
    - staging

```
terraform init

# to create workspace
terraform workspace new <staging|production>

# to switch workspace
terraform workspace select <staging|production>

terraform plan
terraform apply
```

## vpc

* Contains scripts for creating security groups for the default VPC
* Setup using the `terraform-deploy` role. Users of the AWS account can assume this role and apply the changes

```
terraform init
terraform plan
terraform apply
```
