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

**New service deploys forever - new tasks keep starting, failing, and getting replaced, never reaching steady state:**
- This is a more severe cousin of the host-header issue above: it's the target group's *health check path itself* getting rejected by the same kind of app-level guard (e.g. a framework's hostname allowlist), not a real user request. ECS considers every new task unhealthy, kills it, starts another, forever - `aws ecs describe-services` shows `rolloutState: IN_PROGRESS` indefinitely and the deployment never completes.
- Confirm with `aws elbv2 describe-target-health` - look at the target's `reason`, not just `state`. A reason like a non-2xx status code on the health check path is the tell.
- The fix belongs in the app, not the infrastructure: the health check route must respond before any such guard runs, since a health probe hits the target's own private IP/port, never a real domain - it can never satisfy a hostname allowlist.
- If a stuck deployment from a previous (broken) build is blocking a newer, already-fixed build from even starting (CodePipeline won't advance a stage's next execution until the current one finishes, and a deployment stuck in this loop never finishes on its own), stop the stuck execution explicitly: `aws codepipeline stop-pipeline-execution --abandon`. The queued execution then proceeds automatically.

**New compute can't reach a shared resource it needs (cache, database, internal API) that other, existing compute reaches fine:**
- This isn't always an ALB/application-facing security group problem - check the *shared* resource's own security group too (an ElastiCache/RDS/internal-service SG), not just the ones this module creates. A new ASG/task's security group is a brand-new identity; nothing automatically grants it access to a shared resource that only allowlists specific, pre-existing security group IDs by reference.
- Symptom is often silent at first: the new compute starts up fine, passes its own health checks, and only fails once a request path that actually touches the shared resource gets exercised - meaning it can look completely healthy right up until the first real request needs the thing it can't reach.
- The fix is almost always a one-line addition to the shared resource's *existing* security group (add the new SG as another allowed source) - never route shared-resource traffic through a wider CIDR or a temporary public exposure just to unblock testing.

**Host-based routing works when tested directly against the ALB, but the same real domain fails (or silently mis-routes) once it's actually fronted by a CDN:**
- A CDN sitting in front of this ALB may not forward the original client's Host header to the origin by default - many CDN "origin request" / "forwarded headers" configurations explicitly exclude Host, substituting the origin's own domain name instead. Confirm this directly (inspect the CDN's actual origin-request/header-forwarding policy) before assuming a `host_header` listener rule will see the domain you expect.
- If Host isn't forwarded, a listener rule written to match the real public domain (e.g. `example.com`) will never fire for CDN-routed traffic - route on what the CDN actually sends (often the origin's own hostname) instead, or change the CDN's header-forwarding config if you need the real Host end-to-end.
- This also affects the application layer, not just the ALB: a framework-level Host allowlist (see the host-header entry above) needs to include whatever Host the CDN actually substitutes, not just the public-facing domain - otherwise every CDN-routed request gets rejected by the app even though the ALB rule and target group are both healthy.

**Two services both use the `internal_test_rule` attachment pattern (see loadbalancer's `enable_internal_test_rule`), and test traffic always reaches the same one regardless of which header value you send:**
- If you extend this pattern to attach a *second* target group the same way, giving both rules the same `internal_test_header_value` (just different priorities), ALB always matches the lower-priority-number rule first - the second rule becomes permanently unreachable through that header, no matter what path or intent the request carries.
- This is easy to miss because both rules still "work" individually when tested in isolation - the bug only shows up once you're testing the *other* service and keep getting the first one's response instead, which can look like an application bug (wrong data, wrong service) rather than a routing one.
- The fix: give each attachment-only rule its own distinct header value, not just a distinct priority. Distinct values make every target independently, unambiguously reachable regardless of rule ordering.

**A pipeline manually re-triggered for a commit it already built fails on an immutable-tag collision:**
- If the image tag is derived from the commit SHA (a common, good pattern - see the ecs-service module's lifecycle notes) and the ECR repo has immutable tags enabled, re-running a pipeline execution for a commit that already pushed successfully will fail at `docker push` with "tag ... cannot be overwritten" - not a real problem, just a duplicate build attempting to push something that's already there.
- Before manually re-triggering, check execution history for an already-succeeded run against the same source revision - a push to the branch already auto-triggers one execution; triggering a second one for the same commit is almost always redundant, not a fix for anything.

**A modern JS/TS build intermittently crashes in CodeBuild with an internal bundler error (e.g. esbuild's "write EPIPE"), not a code or dependency problem:**
- `BUILD_GENERAL1_SMALL` (3GB RAM) is frequently too small for an SSR/bundled frontend build - the bundler's own worker process gets OOM-killed mid-build, which surfaces as an opaque internal-pipe error, not an out-of-memory message, making it easy to mistake for a flaky or code-level issue.
- Confirm by checking actual memory pressure during the build if possible, but the pragmatic fix is simpler: bump the CodeBuild project's `computeType` one tier up (e.g. to `BUILD_GENERAL1_MEDIUM`) and see if the same build stops failing - cheap to test, and a one-time project setting, not a buildspec or code change.

**`RegisterTaskDefinition` rejects a container definition with "the secret name must be unique and not shared with any new or existing environment variables":**
- ECS validates that no key name appears in *both* `environment` and `secrets` on the same container - if a config key is already being injected via `container_secrets` (sourced from Secrets Manager), it can't also be added as a plain `container_environment` entry, even with the same intended value.
- This is a useful check, not just an obstacle: it means a key you expect to be "missing" from the plain environment variables may actually already be present - injected via the secret instead. Check both lists before concluding a config value isn't set at all.

**A security group with a dangerously open rule (e.g. a database port open to `0.0.0.0/0`) shows up as "unattached" in an audit - is it actually safe to ignore?**
- No. An unattached security group is not currently exploitable, but it's not harmless either - it's a loaded gun left on the table. Nothing stops a future `terraform apply`, a copy-pasted module, or someone reattaching it "to get something working quickly" from putting a real resource behind that same open rule again, with nobody re-reviewing the rule at that point since the group already existed.
- A routine "list all security groups in the account" audit (not just the ones referenced by current resources) is what surfaces these - they're invisible if you only look at what's actively in use. Check every region, not just the ones you think are active: a security posture can be excellent in your primary region and completely absent in an old default-VPC region nobody's touched in years.
- The fix is to delete the group outright once confirmed unattached (zero ENIs, zero instances, zero other security groups referencing it as a source) - not just tighten its rule and leave it sitting around. A correctly-locked-down-but-still-existing group with a misleading name is still a trap for whoever finds it next.

**`printenv`/`env` inside an `aws ecs execute-command` session shows only a handful of OS-level variables, not the secrets/config actually injected into the running app:**
- `execute-command` spawns a brand-new shell process inside the container's namespace via SSM - it does not inherit the environment of the container's actual entrypoint process (PID 1). Only PID 1 gets the full set of variables the container runtime injected at launch (including anything sourced from a secrets manager); a separately-exec'd shell only sees whatever's baked into the image itself.
- This is easy to misread as "the secret isn't actually being injected" when it's really just an artifact of how the shell was spawned - the app can be working perfectly with a fully-populated environment while the exec session you're debugging from sees almost none of it.
- Read the real environment directly from `/proc/1/environ` instead (`cat /proc/1/environ | tr '\0' '\n'`) - that's PID 1's actual environment, not the exec shell's. Note this caveat is specific to SSM-based exec; a plain `docker exec` run directly on the host (not through the ECS/SSM agent) does inherit the container's full launch-time environment by default.
