terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Partial backend config: the bucket/key/region live in backend.hcl (copy
  # backend.hcl.example), so one example works for any account without editing
  # code. `terraform init -backend-config=backend.hcl`.
  backend "s3" {}
}
