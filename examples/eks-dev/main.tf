# Dev environment: a VPC and an EKS cluster composed from the module library.
#
# Dev trades resilience for cost on purpose:
#   - two AZs and the vpc module's single shared NAT gateway
#   - public API endpoint so kubectl works from laptops and CI
#   - small SPOT node group that can scale to a single node
# See ../eks-prod for the same stack with the production choices.

module "vpc" {
  source = "../../aws/Modules/vpc"

  name_prefix          = var.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "eks" {
  source = "../../aws/Modules/eks"

  name_prefix        = var.name_prefix
  kubernetes_version = var.kubernetes_version

  # Control plane ENIs span both tiers; nodes only ever land in private subnets,
  # so no worker gets a public IP.
  subnet_ids            = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_group_subnet_ids = module.vpc.private_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = true

  node_instance_types = var.node_instance_types
  node_capacity_type  = "SPOT"
  node_desired_size   = var.node_desired_size
  node_min_size       = 1
  node_max_size       = var.node_max_size

  # Short window: a torn-down dev cluster shouldn't leave a key billing for a month.
  secrets_kms_deletion_window_days = 7
}
