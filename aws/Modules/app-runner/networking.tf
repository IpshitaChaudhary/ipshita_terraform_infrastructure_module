# Opt-in VPC connector - without one, App Runner can only reach the public
# internet, which pushes people toward exposing a database or cache
# publicly just so App Runner can reach it (exactly the kind of exposure
# found in real account audits this whole repo is informed by). Set
# vpc_connector_subnet_ids to route egress through private subnets instead.
resource "aws_apprunner_vpc_connector" "this" {
  count = length(var.vpc_connector_subnet_ids) > 0 ? 1 : 0

  vpc_connector_name = "${var.name_prefix}-vpc-connector"
  subnets            = var.vpc_connector_subnet_ids
  security_groups    = var.vpc_connector_security_group_ids
}

resource "aws_apprunner_auto_scaling_configuration_version" "this" {
  auto_scaling_configuration_name = "${var.name_prefix}-autoscaling"
  min_size                        = var.autoscaling_min_size
  max_size                        = var.autoscaling_max_size
  max_concurrency                 = var.autoscaling_max_concurrency
}
