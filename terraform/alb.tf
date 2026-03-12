# Application Load Balancer
resource "aws_lb" "main" {
  name               = "deswik-alb"
  internal           = false         # Public facing
  load_balancer_type = "application" # HTTP/HTTPS traffic
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# Target Group for ECS tasks
resource "aws_lb_target_group" "app" {
  name        = "deswik-tg"
  port        = 3000 # App is listening on port 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # Route traffic to the IP address of the task (required for Fargate)

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2 # Consecutive successful responses before the target is marked healthy
    unhealthy_threshold = 3 # Consecutive failed responses before the target is marked unhealthy
    interval            = 30
  }
}

# ALB Listener
# Listens on port 80 and forwards to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
