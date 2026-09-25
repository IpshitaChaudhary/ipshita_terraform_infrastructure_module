# AWS Resources Created by `aws/`

A reference for exactly what this module provisions, grouped by submodule. This is not a repeat of the README's request-flow diagram - it's the concrete list of AWS resource types you'd see created in the account after `terraform apply`, useful for a cost/blast-radius review before running it against a real account.

## `Modules/capacity/` - compute

| Resource | Purpose |
|---|---|
| `aws_ecs_cluster` | The ECS cluster both services run in. |
| `aws_ecs_capacity_provider` + `aws_ecs_cluster_capacity_providers` | Ties the ASG below to the cluster as its EC2 capacity source, with managed scaling. |
| `aws_launch_template` | Defines the EC2 instance config (AMI, instance type, ECS agent bootstrap) used by the ASG. |
| `aws_autoscaling_group` | The pool of EC2 instances that register into the ECS cluster as container instances. |
| `aws_iam_role` + `aws_iam_instance_profile` | The instance role each EC2 container instance assumes, with the AWS-managed ECS and SSM policies attached. |

## `Modules/loadbalancer/` - networking

| Resource | Purpose |
|---|---|
| `aws_lb` | The Application Load Balancer itself. |
| `aws_lb_target_group` (x2: `backend`, `frontend`) | One target group per service - ECS registers tasks into these automatically. |
| `aws_lb_listener` (x2: `http`, `https`) | HTTP listener (redirects to HTTPS) and the HTTPS listener that actually serves traffic. |
| `aws_lb_listener_rule` (x2: `backend_host`, `frontend_host`) | Host-header rules on the HTTPS listener that route to the matching target group. |

## `Modules/security/` - security groups

| Resource | Purpose |
|---|---|
| `aws_security_group` (x2: `alb`, `container_instances`) | One SG for the ALB, one for the EC2 container instances. |
| `aws_vpc_security_group_ingress_rule` (x3) | ALB: allow 80 and 443 from the internet. Container instances: allow traffic only from the ALB's security group. |
| `aws_vpc_security_group_egress_rule` (x2) | Unrestricted egress on both SGs (outbound to pull images, call APIs, etc.). |

## `Modules/ecs-service/` - the app itself

Instantiated twice (once for `backend`, once for `frontend`) by the root module.

| Resource | Purpose |
|---|---|
| `aws_cloudwatch_log_group` | Where the container's stdout/stderr ends up - one per service. |
| `aws_ecs_task_definition` | The container spec: image, CPU/memory, port mappings, log driver config. |
| `aws_ecs_service` | Keeps the desired count of tasks running on the cluster and registered with its target group. |

## `Modules/secrets/` - optional secrets access

Only created when the optional Secrets Manager wiring is enabled for the backend.

| Resource | Purpose |
|---|---|
| `aws_iam_role_policy` (`read_backend_secret`) | Grants the backend's task execution role `secretsmanager:GetSecretValue` on exactly one secret ARN - not created if this feature isn't used. |

## `Modules/ecr/` - existing image repos (no resources)

This module creates nothing. It's `data "aws_ecr_repository"` lookups only, by name, for the backend and frontend repos - they're assumed to already exist (built/pushed elsewhere), so `terraform apply` can never touch or recreate them.
