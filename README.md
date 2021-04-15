# Terraform Base

These are the base "projects" I use in a mono-repo~ish way to manage an AWS Account for tutorials.

## Project Descriptions

### [Terraform Bootstrap](/terraform_bootstrap)

This project is responsible for creating all the resources that Terraform uses to manage Terraform in AWS.

- S3 Bucket for terraform state files (json blobs)
- KMS Key to encrypt terraform state files
- DynamoDB for locking state files to prevent corruption in a multi-user environment

### [Terraform IAM](/terraform_iam)

Centrally managed IAM resources that are useful to have created across tutorials.

- Service Linked Roles
- Standard Required Roles by AWS Services

### [Terraform SSM](/terraform_ssm)

Resources required to get SSM Session Manager working for SSH-less EC2 access.

- CloudWatch Log Group for storing session logs
- KMS Key to encrpyt the logs
- SSM Session application configuration
- IAM Role for EC2 instances to use the KMS key to encrypt the sessions

## How-To Use

### Replace Known "Broken" Values

Common values you need to replace because they're only useful for me:

- Anything mentioning: hpydev
- Anything referencing: 666236088316
- Likely the region choice: us-east-2

For the most part, if you search for "TODO:" you'll find all the places that are important.

### `.tfvars` Files

In some projects, like Terraform Bootstrap, there is a `terraform.tfvars.example` file which should be copied or moved
to `terraform.tfvars` and then have the values replaced with the values you'd like to use.

At the moment I add the `terraform.tfvars` to the `.gitignore` file so that they are not accidentally checked in,
in the event they contain sensitive information. If that's annoying remove its reference from `.gitignore` and check
the file into source control.

These [Variable Definitions Files](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files)
can be quite helpful for creating more advanced CI/CD workflows. 

### Make

After reviewing and fixing up the resources here, you can use `Make` to run the commands:

```bash
make init
# ... sets up the project's dependencies
make plan
# ... a plan output
make apply
# ... logs showing the resources being created/managed
```

As you add more resources you might want to use:

```bash
make fmt
```

To keep your terraform code looking sharp.

After a while, you'll want to update your Terraform Modules and Providers:

```bash
make clean
make upgrade
```
