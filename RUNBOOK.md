# Runbook: `aws/` ECS module

Operational reference for deploying, rolling back, and troubleshooting the ECS-on-EC2 stack this module builds. Pairs with [README.md](README.md), which covers what each file/module does - this covers what to actually *do* with it.

## Pre-deploy checklist

Before running `terraform apply` for the first time (or against a new environment), confirm:

- [ ] The VPC, public/private subnets, ACM certificate, and IAM roles (`ecsTaskExecutionRole`, `ecsTaskRole`) referenced in your `terraform.tfvars` already exist - this module only reads them, it never creates them.
- [ ] The ECR repositories named in `backend_repository_name`/`frontend_repository_name` already exist and have at least one image pushed - `terraform apply` will fail at the `ecr` module's data lookup otherwise.
- [ ] `backend_container_image`/`frontend_container_image` point at a real, pulled tag (not `:latest` if you want reproducible deploys - a fixed tag makes rollback by re-apply meaningful).
- [ ] If using `backend_secret_name`, the Secrets Manager secret already exists and is populated - this module grants read access to it, it doesn't create or populate it.
- [ ] `instance_type` is actually sized for what you're running - the capacity ASG bin-packs both services onto shared EC2 instances, so undersizing causes scheduling failures and oversizing wastes money silently (verify against real usage, don't just trust a default).
