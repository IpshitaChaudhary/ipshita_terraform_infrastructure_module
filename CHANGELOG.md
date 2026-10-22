# Changelog

All notable changes to this repository, in the order they happened.

## 2026-10-22

- `security`: fixed `terraform fmt` alignment in the ingress/egress rules - whitespace only, but it had kept the root CI check red.
- `ssm-access/`: new module for per-person server access - Session Manager Run As preferences (each person lands as their own Linux user from the `SSMSessionRunAs` tag instead of the shared `ssm-user`), a start-session policy scoped to tagged instances, optional session transcripts to CloudWatch, and a boot script for launch templates that creates named users with key-only login, passwordless sudo and sudo session recording.
- `RUNBOOK.md`: documented Run As failure modes, why a private bastion address times out from an office network, and why personal private keys don't belong on a bastion.
- CI: added `ssm-access` to the module validation matrix.

## 2026-10-21

- `elasticache/`: new module - a Valkey/Redis replication group with at-rest and in-transit encryption always on, and ingress granted only by security group reference (no CIDR input exists). Built from a real finding: a cache port open to `0.0.0.0/0` while the compute actually using it was never allowlisted, so correctly tightening the rule would have silently broken the app.
- `cloudfront`: added an optional short-TTL HTML cache tier (`enable_html_cache`, off by default) between "never cache" and the long-cache static tier, plus `no_cache_path_patterns` - explicit CachingDisabled behaviors for personalized paths, ordered ahead of everything else, with a precondition on CloudFront's 25-behavior default limit.
- `RUNBOOK.md`: documented the 502 caused by excluding the viewer Host header against an ALB origin (TLS name validation against the ALB's own hostname), and a rollback-first, throwaway-behavior method for isolating which part of a multi-change CloudFront update broke it.
- CI: added `elasticache` to the module validation matrix.

## 2026-10-17

- `iam`: added opt-in, data-driven human access groups (`human_access_groups`) - a map of group name to managed policy ARNs, separate from the existing ECS task roles. Deliberately doesn't manage group membership, so rotating a person in/out never touches this module's state.
- `README.md`: added the `iam/` module's missing prose section (it previously only had a one-line tree comment), covering both the ECS roles and the new human access groups capability.
- `RUNBOOK.md`: documented the retired-but-still-resolvable managed policy gotcha - a policy ARN can resolve successfully while being retired from new attachments in favor of a renamed replacement (check `IsAttachable`, not just that it exists).
- `RUNBOOK.md`: documented that adding a new access-control layer next to an unrestricted old one doesn't secure anything - the old path has to actually be restricted too, not just left alone while the new one gets tested in isolation.

## 2026-10-16

- `RUNBOOK.md`: documented the orphaned-but-dangerous security group trap - an unattached group with an open rule isn't harmless, it's a loaded gun waiting for something to get reattached to it; found via a full account-wide audit, not by looking at active resources.
- `RUNBOOK.md`: documented the ECS Exec vs plain `docker exec` environment gotcha - a shell spawned via `aws ecs execute-command` doesn't inherit the container's actual injected environment the way a direct `docker exec` on the host does, easy to misdiagnose as a missing secret.
- `RUNBOOK.md`: documented a public-bucket investigation methodology - an empty grep of your own codebase doesn't prove a public bucket policy is a misconfiguration, since a third-party service (a CDN, an external processor) pulling from it as an origin won't show up there; measure real traffic non-destructively before restricting anything.

## 2026-10-15

- `RUNBOOK.md`: documented two routing/CI gotchas found extending the attachment-rule pattern to a second service - sharing one header value across two attachment-only rules makes the lower-priority one permanently unreachable, and manually re-triggering a pipeline for an already-built commit collides on an immutable ECR tag.
- `RUNBOOK.md`: documented a CodeBuild sizing gotcha - an opaque bundler crash (e.g. esbuild "write EPIPE") is frequently just an OOM kill on undersized compute (`BUILD_GENERAL1_SMALL`), not a real build problem.
- `RUNBOOK.md`: documented `RegisterTaskDefinition`'s environment/secrets key-conflict validation - a key can't appear in both `container_environment` and `container_secrets`, which is a useful signal (the key may already be injected via the secret) rather than just a blocker.

## 2026-10-14

- `ecs-service`: added an `ordered_placement_strategy` (spread by AZ, then by host) - `desired_count >= 2` previously didn't guarantee real redundancy; every replica could land on the same instance.
- `ecs-service`: added Application Auto Scaling (`autoscaling.tf`) - task-count scaling via tiered CPU-based Step Scaling, separate from and upstream of the EC2 Capacity Provider's own instance-count scaling. Without it, real traffic growth had no automatic response at all.
- `RUNBOOK.md`: documented two silent-failure modes found standing up parallel compute - a shared resource's own security group not trusting new compute by default, and a CDN not forwarding the real Host header to the origin (breaking both ALB host-header rules and app-level Host allowlists).
- `README.md`/`RESOURCES.md`: cross-referenced all of the above.

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
