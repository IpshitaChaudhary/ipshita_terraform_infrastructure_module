output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "container_instances_security_group_id" {
  value = aws_security_group.container_instances.id
}
