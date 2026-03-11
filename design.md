


## Core Infrastructure:
### Compute and Containers
- ECS
- EC2

### Networking
- VPC
- Subnets:
- Route53
- Elastic Load Balancing

### Data
- RDS

### Observability
- CloudWatch
- X-Ray

### Additional Notes






## Data Migration: 







## Security
### Services Used
- **ACM (Certificate Manager)**: Provides the SSL/TLS certificate that the ALB uses to handle HTTPS traffic on port 443 from users.
- **Secrets Manager**: Stores sensitive credentials such as DB passwords so they are never hardcoded.
- **Security Groups**: ALB, ECS and RDS each have separate least-privilege Security Groups e.g. ALB only accepts inbound on ports 80/443, ECS only accepts traffic from the ALB on port 8080, and RDS only accepts traffic from ECS on port 1433.
- **IAM (Identity and Access Management)**: Least-privilege IAM roles will be assigned to each service e.g. the ECS task role will only have permissions to pull images from ECR, read secrets from Secrets Manager, and write logs to CloudWatch.

### Additional Notes
- For the MVP we are using public subnets for the ECS tasks. This was done for cost and simplicity reasons. However for production we would move the ECS tasks to private subnets behind a NAT Gateway for additional security (ensuring nothing external can initiate direct connection).
<!-- - WAF (Web Application Firewall) would be added post-MVP to protect against common web exploits such as SQL injection etc., sitting in front of the ALB to inspect all incoming traffic. -->



## CI/CD Pipeline:
### Tools
- GitHub Actions
- Terraform
- ECR

### Pipelines
- CI/Build Pipeline
- CD/Deploy Pipeline

