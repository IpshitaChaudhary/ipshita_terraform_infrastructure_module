# Two distinct roles, not one - App Runner itself needs to pull from ECR
# (the access role), which is a completely different concern from what the
# RUNNING application code is allowed to call (the instance role). Folding
# both into one role would let application code assume ECR-pull permissions
# it never needs, and vice versa.
data "aws_iam_policy_document" "apprunner_build_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "apprunner_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "access" {
  name               = "${var.name_prefix}-apprunner-access-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_build_assume_role.json
}

resource "aws_iam_role_policy_attachment" "access_ecr" {
  role       = aws_iam_role.access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Empty by default, same philosophy as the lambda module's execution role -
# the running application only gets what's explicitly granted via
# extra_instance_policy_arns, never a broad default.
resource "aws_iam_role" "instance" {
  name               = "${var.name_prefix}-apprunner-instance-role"
  assume_role_policy = data.aws_iam_policy_document.apprunner_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "instance_extra" {
  for_each   = toset(var.extra_instance_policy_arns)
  role       = aws_iam_role.instance.name
  policy_arn = each.value
}

resource "aws_apprunner_service" "this" {
  service_name = "${var.name_prefix}-service"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.access.arn
    }

    image_repository {
      image_identifier      = var.image_identifier
      image_repository_type = "ECR"

      image_configuration {
        port                          = tostring(var.port)
        runtime_environment_variables = var.environment_variables
      }
    }
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.instance.arn
  }
}
