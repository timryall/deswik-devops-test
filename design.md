Notes
- Currently we are using public subnets for the MVP - for cost and simplicity reasons. However for production we would move the ECS tasks to private subnets behind a NAT Gateway.
- RDS  is isolated in private subnets with no internet exposure for security purposes
- Although CW dashboard was not mentioned explicitly, one was added as it is a key observability tool for debugging the deployment
- HTTP on port 80 is used for MVP simplicity. Production would use HTTPS on port 443 with an AWS Certificate Manager (ACM) certificate attached to the ALB, and port 80 would redirect to 443.