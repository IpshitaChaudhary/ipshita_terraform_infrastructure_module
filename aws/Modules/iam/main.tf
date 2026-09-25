data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Pulls container images, writes logs, resolves task-definition-level secrets.
# This is what ECS itself assumes to *start* the task.
resource "aws_iam_role" "task_execution" {
  name               = "${var.name_prefix}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_execution_extra" {
  for_each   = toset(var.extra_execution_policy_arns)
  role       = aws_iam_role.task_execution.name
  policy_arn = each.value
}

# What the *application code inside the container* is allowed to do at
# runtime (call other AWS APIs, etc). Empty by default on purpose - attach
# whatever the app actually needs via extra_execution_policy_arns-style
# wiring in the caller, don't grant broad access here as a default.
resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}
