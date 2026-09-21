resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.family}"
  retention_in_days = 14
}

# EC2 launch type: no network_mode set (defaults to "bridge", left implicit
# on purpose), no requires_compatibilities needed for cpu/memory validation
# since only memoryReservation (soft) is set at the container level and no
# top-level cpu/memory is set either.
resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name              = var.container_name
      image             = var.container_image
      memoryReservation = var.memory_reservation
      essential         = true
      environment       = var.container_environment
      secrets           = var.container_secrets

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.family
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name                   = var.service_name
  cluster                = var.cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  enable_execute_command = var.enable_execute_command

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
    base              = 0
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
