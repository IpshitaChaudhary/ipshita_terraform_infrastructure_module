# Existing account-level task roles - referenced by name, not managed here.
data "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_role" "ecs_task_role" {
  name = var.ecs_task_role_name
}

module "security" {
  source = "./Modules/security"

  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id
}

# Optional: only created if you actually supplied a Secrets Manager secret name.
module "secrets" {
  count  = var.backend_secret_name == "" ? 0 : 1
  source = "./Modules/secrets"

  name_prefix         = var.name_prefix
  execution_role_name = var.ecs_task_execution_role_name
  backend_secret_name = var.backend_secret_name
}

module "ecr" {
  source = "./Modules/ecr"

  backend_repository_name  = var.backend_repository_name
  frontend_repository_name = var.frontend_repository_name
}

module "capacity" {
  source = "./Modules/capacity"

  name_prefix                           = var.name_prefix
  cluster_name                          = var.ecs_cluster_name
  instance_type                         = var.instance_type
  key_name                              = var.key_name
  subnet_ids                            = var.private_subnet_ids
  container_instances_security_group_id = module.security.container_instances_security_group_id
  asg_min_size                          = var.capacity_asg_min_size
  asg_max_size                          = var.capacity_asg_max_size
  asg_desired_capacity                  = var.capacity_asg_desired_capacity
}

module "loadbalancer" {
  source = "./Modules/loadbalancer"

  name_prefix               = var.name_prefix
  alb_name                  = var.alb_name
  vpc_id                    = var.vpc_id
  subnet_ids                = var.public_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  acm_certificate_arn       = var.acm_certificate_arn
  https_listener_ssl_policy = var.https_listener_ssl_policy
  backend_container_port    = var.backend_container_port
  frontend_container_port   = var.frontend_container_port
  backend_host_header       = var.backend_host_header
  frontend_host_header      = var.frontend_host_header
}

module "backend_service" {
  source = "./Modules/ecs-service"

  aws_region             = var.aws_region
  family                 = var.backend_task_family
  service_name           = "${var.name_prefix}-backend-svc"
  cluster_id             = module.capacity.cluster_id
  capacity_provider_name = module.capacity.capacity_provider_name
  execution_role_arn     = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn          = data.aws_iam_role.ecs_task_role.arn
  container_name         = var.backend_container_name
  container_image        = var.backend_container_image
  container_port         = var.backend_container_port
  memory_reservation     = var.backend_memory_reservation
  container_environment  = var.backend_container_environment
  container_secrets      = local.backend_container_secrets
  target_group_arn       = module.loadbalancer.backend_tg_arn
  desired_count          = var.backend_desired_count
  enable_execute_command = true
}

module "frontend_service" {
  source = "./Modules/ecs-service"

  aws_region             = var.aws_region
  family                 = var.frontend_task_family
  service_name           = "${var.name_prefix}-frontend-svc"
  cluster_id             = module.capacity.cluster_id
  capacity_provider_name = module.capacity.capacity_provider_name
  execution_role_arn     = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn          = data.aws_iam_role.ecs_task_role.arn
  container_name         = var.frontend_container_name
  container_image        = var.frontend_container_image
  container_port         = var.frontend_container_port
  memory_reservation     = var.frontend_memory_reservation
  target_group_arn       = module.loadbalancer.frontend_tg_arn
  desired_count          = var.frontend_desired_count
}
