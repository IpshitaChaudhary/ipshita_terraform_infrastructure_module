provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  # Refuse to plan/apply against any account not listed. With one CLI profile
  # per account it is easy to run the dev stack with the prod profile (or the
  # reverse); this turns that mistake into an error before anything changes.
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      Stack       = "${var.name_prefix}-eks"
    }
  }
}
