# Examples: live environments built from the module library

Each folder is a complete root module you can `init`/`plan`/`apply` on its own.
They show how the standalone modules under `aws/Modules/` are meant to be wired
together, and CI validates them on every pull request, so a module change that
breaks a caller fails before it merges.

| Example | What it builds | Key choices |
|---|---|---|
| [`eks-dev/`](./eks-dev) | VPC + EKS | 2 AZs, single NAT, public API endpoint, SPOT nodes (1-3), 7-day KMS deletion window |
| [`eks-prod/`](./eks-prod) | VPC + EKS | 3 AZs (enforced), private-only API endpoint, ON_DEMAND nodes (one per AZ minimum), 30-day KMS deletion window |

Both pin Kubernetes `1.31` so a control-plane upgrade is a reviewed change, and
both keep worker nodes in private subnets only.

## Using one

```bash
cd examples/eks-dev
cp backend.hcl.example backend.hcl            # state bucket, key, region
cp terraform.tfvars.example terraform.tfvars  # account, region, CIDRs, sizes

terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan

$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

`backend.hcl` and `terraform.tfvars` are git-ignored.

## Guard rails built in

- **`allowed_account_ids`** (required, non-empty): the AWS provider refuses to
  run against any other account. Running the dev stack with the prod profile
  becomes an error at plan time instead of a change to the wrong account.
- **Partial S3 backend**: the backend block is empty in code and filled from
  `backend.hcl`, so dev and prod can't accidentally share a state file, and
  `use_lockfile = true` gives S3-native state locking (Terraform 1.10+) without
  a DynamoDB table.
- **`default_tags`**: every resource gets `Environment`, `ManagedBy` and
  `Stack` tags from the provider, so cost and ownership reports work without
  tagging each resource by hand.

## Reaching the prod cluster

`eks-prod` turns the public API endpoint off. `kubectl`, Helm and CI deploys
must run from inside the VPC: a VPN, an instance reached through Session
Manager (see `aws/Modules/ssm-access/`), or a CI runner in a private subnet.
If you need a public endpoint for a while, flip `endpoint_public_access` in
`eks-prod/main.tf` in a reviewed change rather than leaving it on by default.

## Cost notes

Neither example is free to leave running. The biggest fixed costs are the EKS
control plane (billed per cluster-hour) and the NAT gateway (per hour plus per
GB). Destroy dev with `terraform destroy` when it isn't in use; the KMS key for
Secrets stays pending deletion for the configured window.
