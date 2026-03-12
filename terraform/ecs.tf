# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "deswik-cluster"
}

# ECS Task Definition
# Defines which containers to run and how to run them
resource "aws_ecs_task_definition" "app" {
  family                   = "deswik-app"
  network_mode             = "awsvpc" # Give each task its own ENI (required for Fargate)
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # 0.25 vCPU
  memory                   = 512 # 0.5 GB

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "deswik-app"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true # If container stops or crashes - entire task is stopped and restarted.

      portMappings = [
        # App is listening on port 3000
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      # Send logs to CloudWatch
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/deswik-app"
          awslogs-region        = "ap-southeast-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/deswik-app"
  retention_in_days = 7
}

# ECS Service
# Maintains desired count of tasks and connects to ALB
resource "aws_ecs_service" "app" {
  name            = "deswik-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true # Required so Fargate can pull from ECR
  }

  # Connect ECS Service to ALB
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "deswik-app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.http] # Ensure ALB listener is created before ECS service
}
