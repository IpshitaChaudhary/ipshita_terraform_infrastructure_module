data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# By default every Session Manager user lands on the instance as the same
# ssm-user, with passwordless sudo - a shared identity, just like a shared
# SSH key. Run As makes each person land as their own Linux user, picked
# from the SSMSessionRunAs tag on their IAM user or role, so sudo logs and
# session recordings on the instance name a real person.
resource "aws_ssm_document" "session_preferences" {
  count = var.manage_session_preferences ? 1 : 0

  # Session Manager only reads preferences from this exact document name.
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager preferences (managed by Terraform)"
    sessionType   = "Standard_Stream"
    inputs = {
      runAsEnabled                = true
      runAsDefaultUser            = var.run_as_default_user
      idleSessionTimeout          = tostring(var.idle_session_timeout_minutes)
      cloudWatchLogGroupName      = var.session_log_group_name == null ? "" : var.session_log_group_name
      cloudWatchEncryptionEnabled = var.session_log_group_name != null
      cloudWatchStreamingEnabled  = var.session_log_group_name != null
      s3BucketName                = ""
      s3EncryptionEnabled         = true
      kmsKeyId                    = ""
      shellProfile = {
        linux = "cd ~"
      }
    }
  })
}

# Attach to the group of people who should reach servers. Sessions are only
# allowed on instances carrying the access tag, never "every instance in the
# account" - broad roles like PowerUser otherwise grant root on all of them
# through ssm-user.
data "aws_iam_policy_document" "start_session" {
  statement {
    sid       = "StartSessionOnTaggedInstances"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/${var.access_tag_key}"
      values   = [var.access_tag_value]
    }
  }

  statement {
    sid       = "UseShellDocument"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:document/SSM-SessionManagerRunShell"]
  }

  # A person can only resume or end their own sessions.
  statement {
    sid       = "ManageOwnSessions"
    actions   = ["ssm:ResumeSession", "ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:session/$${aws:username}-*"]
  }

  statement {
    sid       = "ListForConsole"
    actions   = ["ssm:DescribeSessions", "ssm:GetConnectionStatus", "ssm:DescribeInstanceInformation", "ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "start_session" {
  name        = "${var.name_prefix}-ssm-start-session"
  description = "Session Manager access limited to instances tagged ${var.access_tag_key}=${var.access_tag_value}"
  policy      = data.aws_iam_policy_document.start_session.json
}
