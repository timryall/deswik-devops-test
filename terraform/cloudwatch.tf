# CloudWatch CPU Alarm
# Triggers when ECS service CPU usage exceeds 80% for 2 consecutive periods
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "deswik-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60 # Check runs every 60s
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers when ECS CPU usage exceeds 80%"

  # Only look at CPU for our custer and service
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }
}
