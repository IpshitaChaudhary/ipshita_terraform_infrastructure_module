output "start_session_policy_arn" {
  description = "Attach to the IAM group of people allowed to open sessions. Give each member an SSMSessionRunAs tag matching their Linux user name."
  value       = aws_iam_policy.start_session.arn
}
