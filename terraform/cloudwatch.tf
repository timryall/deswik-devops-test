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

# CloudWatch Dashboard
# Visualise key metrics and logs in a single pane of glass
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "deswik-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ECS CPU Utilisation
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU Utilisation"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ECS", "CPUUtilization",
              "ClusterName", aws_ecs_cluster.main.name,
            "ServiceName", aws_ecs_service.app.name]
          ]
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "CPU Alarm Threshold"
                value = 80
                color = "#ff0000"
              }
            ]
          }
        }
      },

      # ECS Memory Utilisation
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS Memory Utilisation"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ECS", "MemoryUtilization",
              "ClusterName", aws_ecs_cluster.main.name,
            "ServiceName", aws_ecs_service.app.name]
          ]
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },

      # ALB Request Count
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Count"
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount",
            "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },

      # ALB HTTP 5XX Errors
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB HTTP 5XX Errors"
          view   = "timeSeries"
          stat   = "Sum"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count",
            "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },

      # ALB Target Response Time
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Response Time (seconds)"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime",
            "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },

      # ECS Running Task Count
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "ECS Running Task Count"
          view   = "timeSeries"
          stat   = "Average"
          period = 60
          region = "ap-southeast-2"
          metrics = [
            ["AWS/ECS", "RunningTaskCount",
              "ClusterName", aws_ecs_cluster.main.name,
            "ServiceName", aws_ecs_service.app.name]
          ]
        }
      },

      # Container Logs
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6
        properties = {
          title   = "Container Logs"
          query   = "SOURCE '/ecs/deswik-app' | fields @timestamp, @message | sort @timestamp desc | limit 50"
          region  = "ap-southeast-2"
          view    = "table"
        }
      },

      # CPU Alarm Status
      {
        type   = "alarm"
        x      = 0
        y      = 24
        width  = 24
        height = 2
        properties = {
          title = "Alarms"
          alarms = [
            aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
          ]
        }
      }
    ]
  })
}