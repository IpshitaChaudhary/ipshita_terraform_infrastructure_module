output "start_session_policy_arn" {
  description = "Attach to the IAM group of people allowed to open sessions. Give each member an SSMSessionRunAs tag matching their Linux user name."
  value       = aws_iam_policy.start_session.arn
}

output "named_users_user_data" {
  description = "Shell script that creates var.named_users with sudo and session recording. Append it to a launch template's user data so instances an Auto Scaling group replaces come up with the same users - hand-created users disappear with the instance."
  value = templatefile("${path.module}/templates/named-users.sh.tftpl", {
    users          = var.named_users
    retention_days = var.session_recording_retention_days
  })
}
