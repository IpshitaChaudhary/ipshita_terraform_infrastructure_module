# ipshita_terraform_infrastructure_module

Reusable, sanitized Terraform modules for common infrastructure patterns. Each top-level folder is a self-contained module for one piece of infrastructure - `ecs/` is the first one, more (EKS, etc.) will be added as siblings over time.

## `ecs/` - AWS ECS on EC2 capacity, with an ALB in front

Stands up a small, self-contained ECS setup for a typical two-service app (a backend API and a frontend web app), running on EC2-launch-type capacity behind an Application Load Balancer.

**Request flow:**

```
Client
  │
  ▼
Application Load Balancer (HTTPS, host-header routing)
  ├─ backend_host_header  → backend target group  ─┐
  └─ frontend_host_header → frontend target group ─┤
                                                     ▼
                                    ECS cluster (EC2 capacity provider)
                                    ├─ backend service  (EC2-launch-type task)
                                    └─ frontend service (EC2-launch-type task)
```

The module assumes you already have a VPC, subnets, an ACM certificate, and the standard ECS IAM roles - it only reads those as input, it never creates or manages them. Everything it *does* create (security groups, the EC2 capacity ASG, the ECS cluster, the ALB, and both services) is new and additive.

### Repository layout

```
ecs/
├── main.tf, variables.tf, outputs.tf, locals.tf, providers.tf
├── terraform.tfvars.example
└── Modules/
    ├── security/      - ALB + capacity-instance security groups
    ├── secrets/        - optional Secrets Manager wiring for the backend
    ├── capacity/       - EC2 launch template, ASG, ECS capacity provider
    ├── ecr/            - looks up existing ECR repos by name
    ├── ecs-service/    - generic ECS task definition + service (used for both apps)
    └── loadbalancer/   - ALB, target groups, listeners, host-header routing rules
```
