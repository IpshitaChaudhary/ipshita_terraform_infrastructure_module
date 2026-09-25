# Changelog

All notable changes to this repository, in the order they happened.

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
