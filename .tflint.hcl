# tflint config shared by every module. Run from the repo root with:
#   tflint --recursive --config "$(pwd)/.tflint.hcl"
# (--recursive otherwise looks for a config inside each module and ignores this one).
# `terraform validate` only proves the HCL parses; tflint catches the things validate
# lets through: unused variables, missing type/description, deprecated syntax, and
# AWS-specific mistakes like invalid instance types.

config {
  call_module_type = "none" # lint each module on its own, don't follow module calls
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Every input and output carries a description - enforce it so new ones do too.
rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}
