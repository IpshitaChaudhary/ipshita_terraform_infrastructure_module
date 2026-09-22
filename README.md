# ipshita_terraform_infrastructure_module

Reusable, sanitized Terraform modules for common infrastructure patterns. Each top-level folder is a self-contained module for one piece of infrastructure - `aws/` is the first one, more (EKS, etc.) will be added as siblings over time.

## `aws/` - AWS ECS on EC2 capacity, with an ALB in front

More building-block modules (VPC, IAM, route tables, security groups, ...) will be added under `aws/Modules/` over time, alongside the ECS-specific ones already there.

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
aws/
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

### Prerequisites

Before running this module, you need (all existing, referenced by the module, never created by it):

- A VPC, with at least one public subnet (for the ALB) and one private subnet (for the ECS capacity instances).
- An ACM certificate covering the domain(s) you'll route through the ALB.
- The standard `ecsTaskExecutionRole` and `ecsTaskRole` IAM roles.
- ECR repositories for your backend and frontend container images (or point `backend_container_image` / `frontend_container_image` at any registry your capacity instances can pull from).
- Optionally, a Secrets Manager secret already created and populated for the backend, if you want secrets injected into the container at launch instead of plain env vars.

### Usage

```bash
cd aws
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your real VPC/subnet/cert/image values

terraform init
terraform plan
terraform apply
```

Once applied, `terraform output alb_dns_name` gives you the ALB's DNS name - point your `backend_host_header` and `frontend_host_header` domains at it (as an alias/CNAME) and the listener rules will route each to the right service.

### What each root file does

| File | Purpose |
|---|---|
| `providers.tf` | Declares the `aws` provider and the required Terraform/provider versions. Deliberately uses local state - fork this into your own project and pick your own backend. |
| `variables.tf` | Every input variable: existing-resource references (VPC/subnets/cert/roles/ECR), naming, EC2 capacity sizing, and backend/frontend service config. Most have sensible generic defaults; the environment-specific ones (VPC, subnets, cert, images) have no default and must be supplied. |
| `locals.tf` | Turns `backend_secret_env_names` into the `{name, valueFrom}` shape the ECS task definition's `secrets` block expects - one entry per key in the backend's Secrets Manager secret. |
| `main.tf` | Wires all the submodules together: security groups → optional secrets → capacity → load balancer → the two ECS services. This is the file that turns the inputs into an actual running stack. |
| `outputs.tf` | The values you'll actually want after `apply`: ALB DNS name, cluster name, both service names, and both ECR repository URLs. |
| `terraform.tfvars.example` | Every variable with clearly-fake placeholder values - copy to `terraform.tfvars` and fill in your real environment. |

### What each submodule does

| Module | Creates | Notes |
|---|---|---|
| `security` | ALB security group (80/443 ingress, open egress) and a capacity-instance security group (all ports from the ALB SG only, open egress) | No inbound SSH port at all - pairs with SSM Session Manager access from `capacity` |
| `secrets` | An IAM role policy granting `secretsmanager:GetSecretValue` + `kms:Decrypt` on one existing secret | Only created when `backend_secret_name` is set (`main.tf` makes it conditional via `count`) - fully optional |
| `capacity` | IAM instance role/profile, EC2 launch template, Auto Scaling Group, ECS capacity provider | AMI is resolved live via SSM (`/aws/service/ecs/optimized-ami/...`), never hardcoded, so it can't silently go stale |
| `ecr` | Nothing - two `data` lookups for existing repos, by name | Never manages the repos, so `apply` can't touch or recreate them |
| `ecs-service` | CloudWatch log group, ECS task definition, ECS service | Generic on purpose - the same module is instantiated twice in `main.tf`, once for backend and once for frontend |
| `loadbalancer` | ALB, two target groups, HTTP→HTTPS redirect listener, HTTPS listener with host-header rules | Frontend is the default action (site root); backend only matches on its specific host header |

### A few things worth knowing

- **EC2 launch type, not Fargate.** Both services share the same capacity instances via ECS's dynamic host-port mapping (bridge networking, left implicit on purpose). This bin-packs multiple containers onto one instance, which is usually cheaper than one Fargate task per service at low/moderate traffic - just make sure the instance type is actually sized for what you're running on it.
- **No hard cpu/memory limits** are set on the task definitions - only a soft `memoryReservation` per container. This is intentional for a shared-capacity setup; add hard limits yourself if you need strict isolation between containers on the same instance.
- **Secrets are opt-in.** Leave `backend_secret_name` empty and the whole `secrets` module and its IAM policy are skipped - useful if you're not ready to wire up Secrets Manager yet.
