output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "dashboard_url" {
  value = "https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}
