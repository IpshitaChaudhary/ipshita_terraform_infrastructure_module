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
    ├── loadbalancer/   - ALB, target groups, listeners, host-header routing rules
    ├── vpc/            - VPC, public/private subnets, NAT gateway, route tables
    ├── iam/            - ECS task execution role + task role
    ├── eks/            - EKS cluster, managed node group, OIDC provider for IRSA
    ├── route53/        - looks up an existing hosted zone, creates one alias record in it
    ├── cloudfront/     - CDN distribution with S3 (static) + ALB (dynamic) origins
    ├── sqs/            - queue with a dead-letter queue and encryption on by default
    ├── sns/            - topic with encryption and a scoped, opt-in policy
    ├── s3/             - bucket with public access blocked, versioned and encrypted by default
    └── lambda/         - function with a least-privilege role and a locked-down function URL
```

> **Note:** `vpc/`, `iam/`, `eks/`, `route53/`, `cloudfront/`, `sqs/`, `sns/`, `s3/`, and `lambda/` are standalone modules, not yet wired into the root `main.tf`. The root module still takes an existing VPC/subnets/IAM roles as input variables (see Prerequisites below) - these modules exist so you can create infrastructure like that with Terraform too, instead of by hand, but plugging their outputs into the root module's inputs (or into each other) is a manual step for now.

### `eks/` - a second compute option, alongside the ECS-on-EC2 setup above

The root module (and everything documented below it) runs on ECS with EC2 capacity. `eks/` is a separate, independent module for teams that would rather run the same kind of workload on Kubernetes instead - it stands up an EKS cluster, a managed node group, and an OIDC provider so pods can assume IAM roles directly (IRSA) instead of inheriting whatever the node's IAM role can do. It takes an existing VPC/subnets as input (e.g. from the `vpc/` module above) and doesn't touch ECS at all - pick one compute model or the other, this module doesn't assume you're using both.

### `route53/` - one DNS record, in a zone you already own

Looks up an existing hosted zone by name and creates a single alias record pointed at whatever you give it (an ALB's `dns_name`/`zone_id`, a CloudFront distribution's `domain_name`/fixed zone ID, etc). Like `ecr/`, the zone itself is only ever read via a `data` source - a shared, customer-facing hosted zone isn't something a reusable module should be able to create, recreate, or delete.

### `cloudfront/` - CDN in front of a split static/dynamic app

One distribution, two origins: an S3 bucket for static assets (`Managed-CachingOptimized` + `Managed-CORS-S3Origin`) and an existing ALB for everything else (`Managed-CachingDisabled` + `Managed-AllViewer`, so session/auth cookies always reach the backend). Uses an Origin Access Identity, not Origin Access Control - OAC's per-request signing to an S3 origin can produce intermittent, edge-location-specific errors that are invisible to `curl` and only reproduce in real browsers at specific edges; OAI has no per-request signing step to fail. The module creates its own OAI and a response headers policy (HSTS, X-Frame-Options, etc.) rather than taking them as inputs, so it's self-contained - a caller only needs to feed the OAI's IAM ARN into their S3 bucket policy. `aliases` defaults to empty, so a distribution can be stood up and fully tested before it ever claims a real domain.

### `sqs/` - a queue that's encrypted and bounded by default

A main queue plus a dead-letter queue (on by default - a queue with no DLQ either silently drops or infinitely retries a poison message). Encrypted by default too, either SQS-managed SSE or a customer KMS key - never left plaintext. The queue policy is opt-in and scoped: pass `allowed_sender_arns` (an SNS topic ARN, an IAM role, etc.) and the module grants exactly `sqs:SendMessage` to exactly those ARNs on exactly this queue; leave it empty and no policy is created at all. This is deliberately the opposite of a `Principal:"*"` policy - a real account audit found queues with wildcard resource policies (publicly writable/readable by anyone), and encryption missing on several others.

### `sns/` - a topic that's encrypted and scoped by default

Same philosophy as `sqs/`: encrypted by default (AWS-managed `alias/aws/sns` key, or your own via `kms_master_key_id`), and the topic policy is opt-in and scoped - pass `allowed_publisher_arns`/`allowed_subscriber_arns` and the module grants exactly `sns:Publish`/`sns:Subscribe` to exactly those ARNs; leave both empty and no policy is created at all. A real account audit found several SNS topics with no KMS key set - this module never starts that way.

### `s3/` - a bucket that's private, versioned, and encrypted by default

The single most important lesson baked into this whole repo: two separate real account audits (dev and prod) each found S3 buckets with a wildcard `Principal:"*"` policy and zero Public Access Block settings - actual customer data (receipts, support uploads) downloadable by anyone, no login required. Every bucket this module creates enables all 4 Public Access Block settings, versioning, and server-side encryption (SSE-S3 by default, or your own KMS key) from the start. The bucket policy is opt-in and scoped like `sqs/`/`sns/` - and even then, it's layered *under* the Public Access Block, not instead of it, so an accidentally-broad policy statement still can't make the bucket public. A caller who genuinely needs public access (which should almost never be the case - use CloudFront + OAI/OAC instead, see `cloudfront/`) has to explicitly override multiple settings, not just forget to set one.

### `lambda/` - a function that's least-privilege and locked down by default

The execution role only gets `AWSLambdaBasicExecutionRole` (write its own logs) by default - a real account audit found a Lambda role with wildcard `cognito-idp:*`/`sns:*` grants on `Resource:*` baked in as inline policies, far broader than the function actually needed. Anything beyond logging is added explicitly per caller via `extra_execution_policy_arns`, scoped to what that function actually touches. The log group is created explicitly too, with a real `log_retention_days` (30 by default) - Lambda's own auto-created group has no expiration at all. A function URL is opt-in (`enable_function_url`) and defaults to `AWS_IAM` auth when enabled - the same audit found a function URL with `AuthType: NONE`, publicly invocable by anyone who found or guessed it, live for years.

### Further reading

- [`RESOURCES.md`](./RESOURCES.md) - the concrete AWS resource types this module creates, grouped by submodule. Useful for a cost/blast-radius review before pointing this at a real account.
- [`RUNBOOK.md`](./RUNBOOK.md) - operational doc: pre-deploy checklist, deploy procedure, rollback, and troubleshooting.

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
