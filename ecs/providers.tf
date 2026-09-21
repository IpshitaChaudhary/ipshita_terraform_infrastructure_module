terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state on purpose: this module is meant to be copied/forked into your
  # own project, where you'll decide your own backend (S3 + DynamoDB lock,
  # Terraform Cloud, etc.) rather than inheriting one from here.
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
