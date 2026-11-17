# Production environment: same composition as ../eks-dev, with the choices
# that matter once real traffic depends on it:
#   - three AZs, so losing one still leaves a majority of nodes
#   - private-only Kubernetes API: kubectl and CI must run from inside the VPC
#     (VPN, a Session Manager bastion from the ssm-access module, or an
#     in-VPC runner)
#   - ON_DEMAND nodes with a floor of one per AZ
#   - 30-day KMS deletion window, the longest recovery time for Secrets

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

  subnet_ids            = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_group_subnet_ids = module.vpc.private_subnet_ids

  endpoint_public_access  = false
  endpoint_private_access = true

  node_instance_types = var.node_instance_types
  node_capacity_type  = "ON_DEMAND"
  node_desired_size   = var.node_desired_size
  node_min_size       = length(var.azs)
  node_max_size       = var.node_max_size

  secrets_kms_deletion_window_days = 30
}
