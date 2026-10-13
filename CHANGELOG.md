# Changelog

All notable changes to this repository, in the order they happened.

## 2026-10-13

- `ecs-service`: added `lifecycle.ignore_changes` on the task definition's `container_definitions` and the service's `task_definition`, once a real CI/CD pipeline owns deploys - without it, Terraform permanently fights every pipeline-driven deploy and a stray `apply` can roll a live service back to a stale image.
- `loadbalancer`: added an optional, off-by-default attachment-only listener rule (`enable_internal_test_rule`) matched on a custom header - lets a brand-new target group satisfy ECS's "must already be attached to a listener" API requirement while standing up a second service in parallel, without risking real traffic on an ALB that's already serving production.
- `RUNBOOK.md`: documented the infinite-redeploy-loop failure mode (a health check path itself getting rejected by an app-level guard, not just a real request) and how a pipeline execution stuck in that loop blocks a newer, already-fixed build from ever starting.
- `README.md`/`RESOURCES.md`: cross-referenced both fixes above.

## 2026-10-05 to 2026-10-07

- Added a `versions.tf` to every module (`vpc`, `iam`, `eks`, `route53`, `cloudfront`, `sqs`, `sns`, `s3`, `lambda`, `app-runner`, `capacity`, `ecr`, `ecs-service`, `loadbalancer`, `secrets`, `security`) pinning the Terraform and AWS provider version constraints instead of leaving them implicit. Spread over three days, module by module.

## 2026-10-01

- Added the `lambda` module's function resource, opt-in Function URL (AWS_IAM auth by default, never open/public), and outputs.
- Added the `app-runner/` module: service with separate access and instance IAM roles, private VPC egress, bounded autoscaling, and health checks. Last module on the original build list.
- Added `ARCHITECTURE.md`: 5 reference patterns showing how the standalone modules combine in practice.

## 2026-09-30

- Added the `sns/` module: topic with encryption by default and an opt-in, scoped publish/subscribe policy (never wildcard).
- Added the `s3/` module: bucket with versioning, encryption, and public access blocked by default, plus an opt-in scoped bucket policy.
- Added the `lambda/` module's least-privilege execution role (function itself followed the next day).

## 2026-09-29

- Added the `cloudfront/` module: CDN distribution with S3 and ALB origins, an origin access identity so the S3 origin stays private, and a security headers response policy.
- Added the `sqs/` module: queue with an attached dead-letter queue and encryption by default.

## 2026-09-28

- Added the `eks/` module: cluster + node group IAM roles, the managed node group itself, and an OIDC provider so pod-level IAM (IRSA) works out of the box.
- Added the `route53/` module: alias record against an existing hosted zone lookup (doesn't create the zone itself).

## 2026-09-25

- Added a GitHub Actions workflow that runs `terraform fmt -check` and `terraform validate` on every push/PR touching a `.tf` file.
- Cross-linked `RUNBOOK.md` and `RESOURCES.md` from the root `README.md`.
- Added an MIT license.

## 2026-09-24

- Completed `RESOURCES.md`: a full reference of every AWS resource type the `aws/` module creates, grouped by submodule (compute, networking, security groups, ecs-service, secrets, ecr).

## 2026-09-23

- Added `RUNBOOK.md`: pre-deploy checklist, deploy procedure, rollback procedure, and troubleshooting guide.

## 2026-09-22

- Added the root `README.md`: overview, request-flow diagram, repository layout, prerequisites, usage instructions, and a submodule reference table.
- Renamed the `ecs/` folder to `aws/` to reflect that more provider-specific modules are planned as siblings.

## 2026-09-21

- Initial commit: the `aws/` Terraform module itself - security groups, optional secrets wiring, EC2 capacity (ASG + ECS capacity provider), the generic `ecs-service` module, and the ALB/listener/target-group setup, wired together in the root module.
