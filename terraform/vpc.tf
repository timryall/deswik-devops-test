# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # 65,536 addresses
  enable_dns_hostnames = true          # Gives Fargate tasks an automatic public DNS hostname
  enable_dns_support   = true          # Allows resources to resolve public domain names within VPC
}

# Public Subnets (one per availability zone)
# We need 2 as the ALB needs at least 2 different AZ's
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # 256 addresses
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true # Automatically assign a public IP address to any subnet resource
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24" # 256 addresses
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
}

# Internet Gateway (Allow traffic to flow in and out of VPC)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Note: 10.0.0.0/16 -> Local is defined by default
  # 0.0.0.0/0 -> IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate Route Table with Subnets (so subnets know which route table to use)
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}
