resource "aws_autoscaling_group" "this" {
  name = "EL2-${var.environment}-${var.service}-ASG"

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  vpc_zone_identifier       = var.subnets

  target_group_arns    = var.target_group_arns
  load_balancers      = var.load_balancers

  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances"
  ]

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scaling policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.environment}-${var.service}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type           = "StepScaling"
  adjustment_type       = "ChangeInCapacity"
  
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.environment}-${var.service}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type           = "StepScaling"
  adjustment_type       = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_upper_bound = 0
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-${var.service}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_scale_up_eval_periods
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = var.cpu_scale_up_periods
  statistic          = "Average"
  threshold          = var.cpu_scale_up_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.environment}-${var.service}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cpu_scale_down_eval_periods
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = var.cpu_scale_down_periods
  statistic          = "Average"
  threshold          = var.cpu_scale_down_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}
