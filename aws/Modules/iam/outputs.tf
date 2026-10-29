output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role (image pull, logs, secret reads at startup)."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the role application code assumes inside the task."
  value       = aws_iam_role.task.arn
}

output "human_access_group_arns" {
  description = "Map of human access group name to its ARN, for the groups created via var.human_access_groups."
  value       = { for name, group in aws_iam_group.this : name => group.arn }
}
