# Runbook: `aws/` ECS module

Operational reference for deploying, rolling back, and troubleshooting the ECS-on-EC2 stack this module builds. Pairs with [README.md](README.md), which covers what each file/module does - this covers what to actually *do* with it.

## Pre-deploy checklist

Before running `terraform apply` for the first time (or against a new environment), confirm:

- [ ] The VPC, public/private subnets, ACM certificate, and IAM roles (`ecsTaskExecutionRole`, `ecsTaskRole`) referenced in your `terraform.tfvars` already exist - this module only reads them, it never creates them.
- [ ] The ECR repositories named in `backend_repository_name`/`frontend_repository_name` already exist and have at least one image pushed - `terraform apply` will fail at the `ecr` module's data lookup otherwise.
- [ ] `backend_container_image`/`frontend_container_image` point at a real, pulled tag (not `:latest` if you want reproducible deploys - a fixed tag makes rollback by re-apply meaningful).
- [ ] If using `backend_secret_name`, the Secrets Manager secret already exists and is populated - this module grants read access to it, it doesn't create or populate it.
- [ ] `instance_type` is actually sized for what you're running - the capacity ASG bin-packs both services onto shared EC2 instances, so undersizing causes scheduling failures and oversizing wastes money silently (verify against real usage, don't just trust a default).

## Deploying

**First-time apply (new environment):**

```bash
cd aws
cp terraform.tfvars.example terraform.tfvars
# fill in terraform.tfvars with your real values
terraform init
terraform plan   # read it - confirm it's only creating, not touching anything you didn't expect
terraform apply
```

Take the `alb_dns_name` output and point your domain(s) at it (as a DNS alias/CNAME) once apply finishes - nothing serves real traffic until DNS is wired up.

**Routine deploy (new container image, existing environment):**

1. Push the new image to ECR under a specific tag (avoid `:latest` - you want to know exactly what's running and be able to roll back to a specific prior tag).
2. Update `backend_container_image` or `frontend_container_image` in your `terraform.tfvars` to the new tag.
3. `terraform plan` - should show only a task definition change (new revision) and the corresponding service update. If it shows anything else changing (security groups, ALB, capacity), stop and figure out why before applying.
4. `terraform apply`.
5. Watch the rollout: `aws ecs describe-services --cluster <cluster> --services <service> --query "services[0].deployments"` - wait for the new deployment to reach `PRIMARY` with `runningCount == desiredCount` before considering the deploy done.
6. Hit the service's actual domain and confirm real traffic looks right (status code, page content) - a healthy ECS deployment doesn't guarantee the *application* is behaving correctly.

## Rolling back

**Bad container image (deployed, now misbehaving):**

1. Revert `backend_container_image`/`frontend_container_image` in `terraform.tfvars` back to the last known-good tag.
2. `terraform plan` - confirm it only touches the task definition/service, same as a routine deploy.
3. `terraform apply`, then watch the rollout the same way as a deploy (step 5 above) - a rollback is just a deploy in the other direction, treat it with the same care, not as a panic button.

**DNS/routing change made things worse (e.g. after switching which domain points where):**

- Never make this kind of change without first writing down the exact previous DNS record (type, value, TTL) - that's your rollback target, and you should be able to restore it from memory/notes, not by reconstructing it under pressure.
- Restoring is the same kind of change as the one that broke it (an UPSERT back to the prior value) - it is not more dangerous to revert than it was to change in the first place, so don't hesitate to do it immediately once something looks wrong.
- After restoring, verify with a real request against the actual domain (not just checking the DNS record value) - a DNS record can be correct while the thing it points at is still unhealthy for an unrelated reason.

**General principle:** always know your rollback target *before* making a change, not after something breaks. If you can't articulate what you'd revert to, you're not ready to make the change yet.

## Troubleshooting

**Service stuck with `runningCount < desiredCount` (tasks won't schedule):**
- Check the capacity provider has room: `aws ecs describe-clusters` / the ASG's current instance count vs. what each task's `memoryReservation` needs. Two services bin-packed on undersized instances is the most common cause.
- Check `aws ecs describe-services ... --query "services[0].events"` - ECS logs *why* it can't place a task (insufficient memory, no container instances, image pull failure) directly here.

**ALB health checks failing (target group shows unhealthy):**
- Confirm the container actually listens on `container_port` and the app's `/health` route (or whatever path the target group checks) returns 200 - a container that's "running" per ECS can still be failing its actual health check.
- Check security groups: the ALB's security group must be allowed inbound to the capacity instances' security group, not just the reverse.

**Requests reach the ALB but the app rejects them (e.g. a hostname/host-header error):**
- If you've added or changed a domain routed through this ALB, check whether the *application itself* validates the incoming Host header (framework-level allowlists exist in some stacks, separate from anything this Terraform module or the ALB controls) - a healthy target group and a correct listener rule don't guarantee the app will accept every hostname pointed at it. Confirm the new hostname is actually allowed by the application before assuming the infrastructure is misconfigured.

**Secrets not resolving in the running container:**
- Confirm `backend_secret_name` matches the real secret name exactly, and that the keys in `backend_secret_env_names` exist in that secret - a typo'd key name fails silently at task launch (check the stopped-task's `stoppedReason` via `aws ecs describe-tasks`, not just the service events).

**Deploy applied cleanly but nothing changed in the running app:**
- Confirm the image tag in `terraform.tfvars` actually changed - reapplying the same tag doesn't force ECS to pull a fresh image or restart tasks, since the task definition itself is unchanged.
