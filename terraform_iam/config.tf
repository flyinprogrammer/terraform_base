terraform {
  ## Backend doesn't get added until after you run this locally.
  backend "s3" {
    acl            = "bucket-owner-full-control"
    # TODO: You will need to replace this value.
    bucket         = "hpydev-devops"
    dynamodb_table = "TerraformStateLocks"
    encrypt        = true
    key            = "terraform_remote_state/terraform_iam.tfstate.json"
    # TODO: You will need to replace this value.
    kms_key_id     = "arn:aws:kms:us-east-2:666236088316:key/278ce60d-b022-4304-9775-1974dfb5d787"
    region         = "us-east-2"
  }
  required_version = "~> 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}
