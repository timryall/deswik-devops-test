Notes
- RDS  is isolated in private subnets with no internet exposure for security purposes
- HTTP on port 80 is used for MVP simplicity. Production would use HTTPS on port 443 with an AWS Certificate Manager (ACM) certificate attached to the ALB, and port 80 would redirect to 443.



## Core Infrastructure:


## Data Migration: 

## Security
### Services Used
- ACM (Certificate Manager): Provides the SSL/TLS certificate that the ALB uses to handle HTTPS traffic on port 443 from users.
- SSM (Systems Manager): Parameter store used to store any credentials so they are not hard coded e.g. DB credentials.
- SG (Security Groups):
- IAM (Identity and Access Management):

### Additional Notes
- For the MVP we are using public subnets for the ECS tasks (i.e. pods). This was done for cost and simplicity reasons. However for production we would move the ECS tasks to private subnets behind a NAT Gateway.



## CI/CD Pipeline:
