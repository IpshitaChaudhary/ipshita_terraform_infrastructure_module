resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-alb-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_v4" {
  security_group_id = aws_security_group.alb.id
  ip_protocol        = "tcp"
  from_port          = 80
  to_port            = 80
  cidr_ipv4          = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_v4" {
  security_group_id = aws_security_group.alb.id
  ip_protocol        = "tcp"
  from_port          = 443
  to_port            = 443
  cidr_ipv4          = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_v4" {
  security_group_id = aws_security_group.alb.id
  ip_protocol        = "-1"
  cidr_ipv4          = "0.0.0.0/0"
}

resource "aws_security_group" "container_instances" {
  name        = "${var.name_prefix}-ecs-ec2-sg"
  description = "ECS-optimized EC2 capacity instances"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-ecs-ec2-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "container_instances_from_alb" {
  security_group_id            = aws_security_group.container_instances.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "All ports from ALB - ECS dynamic host port mapping"
}

resource "aws_vpc_security_group_egress_rule" "container_instances_all_v4" {
  security_group_id = aws_security_group.container_instances.id
  ip_protocol        = "-1"
  cidr_ipv4          = "0.0.0.0/0"
}
