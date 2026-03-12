# Security Group for ALB
# Allows inbound HTTP traffic from the internet
resource "aws_security_group" "alb" {
  name        = "deswik-alb-sg"
  description = "Allow inbound HTTP traffic to ALB"
  vpc_id      = aws_vpc.main.id

  # HTTP inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NOTE: protocol = -1 indicates all ports on all protocols 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for ECS Tasks
# Only allows inbound traffic from the ALB security group
resource "aws_security_group" "ecs_tasks" {
  name        = "deswik-ecs-tasks-sg"
  description = "Allow inbound traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  # App is listening on port 3000
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Only allow from ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
