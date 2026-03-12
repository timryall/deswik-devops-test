# .NET Application AWS Migration MVP (Part 1: Design Challenge)

## High Level Overview
The application runs on ECS-orchestrated containers on Fargate, with images stored in ECR and data in RDS (SQL Server). Legacy data is migrated via AWS DMS. All resources sit within a VPC, segmented into public/private subnets across two AZs for security and high availability. Users connect via a domain name, which Route 53 resolves to an ALB that distributes traffic across ECS tasks. Infrastructure and Dockerfiles live in GitHub, with CI/CD via GitHub Actions — CI triggers on PR to Main (tests, builds/pushes image to ECR, outputs Terraform plan), CD triggers on merge (Terraform apply, ECS deployment). Observability is provided by CloudWatch (logs/metrics) and X-Ray (distributed tracing).


### MVP Final High Level Architecture
Security services (ACM, Secrets Manager, IAM, Security Groups) and the DMS migration architecture are omitted from this diagram for brevity — both are detailed in the sections below.

![MVP Final High Level Architecture](./imgs/p1_mvp_architecture_diagram.png)


## Core Infrastructure
### Compute and Containers
- **ECS**: Manages container orchestration — lower operational overhead than EKS, which would be overkill for a single .NET application MVP.
- **Fargate**: Serverless compute engine that hosts the containers — no EC2 instances or ASGs to manage. Chosen for its simplicity and reduced operational overhead, making it well suited for an MVP.
### Networking
- **VPC**: Isolates all infrastructure, controlling public/private access and inter-resource communication.
- **Subnets**: Two public and two private subnets across two AZs — minimises exposure per resource (e.g. RDS in private) and enables high availability.
- **ALB**: Spans both public subnets, acting as the single entry point and distributing traffic across ECS tasks.
- **Route 53**: Resolves the application domain to the ALB IP, abstracting any IP changes from users.
### Data
- **RDS (SQL Server)**: Direct AWS equivalent of the legacy database, ensuring application compatibility. Preferred over self-hosting on EC2 as AWS manages backups, patching, and failover. A synchronous standby replica in a separate AZ provides resilience.
### Observability
- **CloudWatch**: Aggregates logs and metrics across all resources. Dashboards and alerts on key metrics enable proactive incident response.
- **X-Ray**: Distributed tracing to identify latency bottlenecks. ServiceLens integrates traces into CloudWatch for unified observability.
### Post MVP
- Expand from two to three AZs for maximum resilience in production.
- Run a cost-benefit analysis on Fargate vs EC2-backed ECS — for higher, more predictable workloads EC2 with an ASG may be more cost-effective.
- Consider Aurora migration if greater performance and scalability are needed (requires moving from SQL Server to MySQL/PostgreSQL).

## Data Migration
To minimise risk, the application will be migrated to ECS first while keeping it pointed at the legacy database. Once the application layer is stable, the database will be migrated separately — changing one thing at a time. The migration will follow these steps:
1. **Provision RDS**: Set up the RDS SQL Server instance in private subnets.
2. **Configure DMS**: Set up a replication instance with source (legacy SQL Server) and target (RDS) endpoints.
3. **Full Load**: DMS copies all existing data to RDS.
4. **CDC (Change Data Capture)**: Continuously captures source changes during the full load so no data is lost.
5. **Validate**: Confirm RDS data matches the source once full load and CDC are in sync.
6. **Cutover**: Re-point the application to RDS and decommission the legacy database.

## Security
- **ACM**: Provides the SSL/TLS certificate for HTTPS traffic on the ALB (port 443). The ALB will also have a HTTP→HTTPS redirect rule on port 80 so all traffic is forced to TLS — ACM alone does not enforce this.
- **Secrets Manager**: Stores all sensitive credentials (DB passwords, connection strings) — nothing hardcoded. Chosen over SSM Parameter Store because it supports automatic secret rotation, which is important for database credentials.
- **Security Groups**: Least-privilege per service — ALB accepts 80/443, ECS accepts only from the ALB security group on 8080, RDS accepts only from the ECS security group on 1433. This means even if something else inside the VPC were compromised, it could not reach the database.
- **IAM**: Least-privilege roles per service — e.g. ECS task role scoped to `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:BatchGetImage`, `ecr:GetDownloadUrlForLayer`, `secretsmanager:GetSecretValue`, `logs:CreateLogStream`, and `logs:PutLogEvents`. No broader permissions granted.
- **KMS**: RDS encryption at rest is enabled so data stored on disk is unreadable without the KMS key — this protects the underlying storage and any snapshots if they were ever accessed directly.
### Post MVP
- Move ECS tasks from public to private subnets behind a NAT Gateway to prevent direct external connections.

## CI/CD Pipeline
### Tools
- **ECR**: Stores Docker images with native ECS integration and built-in image scanning.
- **Terraform**: Manages all AWS infrastructure as code — version controlled, peer reviewed, and automatically deployed.
- **GitHub Actions**: Runs pipelines within the existing repository — no separate tooling server required.

### Pipelines
- **CI/Build Pipeline**: Triggers on PR to Main — runs tests/linting/security checks, builds and pushes Docker image to ECR, outputs Terraform plan for review.
- **CD/Deploy Pipeline**: Triggers on merge to Main — runs Terraform apply and deploys the new image to ECS.