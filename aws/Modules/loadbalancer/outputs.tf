output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB - the alias or CNAME target for Route 53 / CloudFront."
  value       = aws_lb.this.dns_name
}

output "backend_tg_arn" {
  description = "ARN of the backend target group."
  value       = aws_lb_target_group.backend.arn
}

output "frontend_tg_arn" {
  description = "ARN of the frontend target group."
  value       = aws_lb_target_group.frontend.arn
}
