# Task-count scaling, separate from and upstream of the EC2 Capacity
# Provider's own instance-count scaling in Modules/capacity. Step Scaling
# (not Target Tracking) is used deliberately so upscale/downscale have
# distinct, explicit thresholds instead of one symmetric target value -
# useful when you want to react faster going up than coming down, which is
# normally what you want (lose capacity slowly, gain it quickly).
resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.autoscaling_min_capacity
  max_capacity       = var.autoscaling_max_capacity

  depends_on = [aws_ecs_service.this]
}

# Tiered: the further CPU is over the alarm threshold, the more tasks get
# added at once, instead of always adding just one and waiting for the next
# evaluation period to catch up with a fast-rising load.
resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.service_name}-scale-up"
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 20
      scaling_adjustment          = 1
    }
    step_adjustment {
      metric_interval_lower_bound = 20
      metric_interval_upper_bound = 40
      scaling_adjustment          = 2
    }
    step_adjustment {
      metric_interval_lower_bound = 40
      scaling_adjustment          = 3
    }
  }
}

# One task at a time on the way down, and only once the alarm's full
# evaluation window has stayed low - never remove capacity on a brief dip.
resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.service_name}-scale-down"
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}
