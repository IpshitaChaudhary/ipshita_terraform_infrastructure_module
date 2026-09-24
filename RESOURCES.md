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
