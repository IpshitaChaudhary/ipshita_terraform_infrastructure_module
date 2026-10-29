output "alb_security_group_id" {
  description = "ID of the ALB security group."
  value       = aws_security_group.alb.id
}

output "container_instances_security_group_id" {
  description = "ID of the container instance security group (only reachable from the ALB)."
  value       = aws_security_group.container_instances.id
}
