# .NET Application AWS Migration MVP
## High Level Overview
Our application will be hosted on containers orchestrated by ECS and run on EC2 instances. Images will be stored in ECR. For our database we will use RDS (SQL Server) and migrate data from the legacy database using AWS DMS (Database Migration Service).

All resources will be encapsulated within a VPC and further segmented into subnets spread across multiple AZs to ensure resource security and high availability.

Users can interact with the application by connecting to the domain name, which Route 53 resolves to the IP of an ALB. The ALB distributes incoming traffic across the ECS tasks running in the cluster.

Infrastructure as code and Dockerfiles will be stored in GitHub with CI/CD managed via GitHub Actions. The CI pipeline triggers on a PR to Main — it runs the test suite, builds and pushes the Docker image to ECR, and outputs a Terraform plan. The CD pipeline triggers on merge to Main — it runs Terraform apply and triggers an ECS deployment with the new image.

Observability is instrumented across all components via CloudWatch for logs and metrics, and X-Ray for distributed tracing.



## Core Infrastructure
### Compute and Containers
- **ECS (Elastic Container Service)**: AWSs simple container orchestration service that manages the running of the application Docker containers. This service allows for easy management (including resource allocation, scaling, restarts etc.) of the containers - at a lower operational overhead than EKS, which would be overkill for a single .NET application MVP.

- **EC2 (Elastic Compute Cloud)**: The compute instances that the containers run on. Chosen over a serverless solution like Fargate as it provides more control and is more cost effective for a predictable MVP workload.

### Networking
- **VPC (Virtual Private Cloud)**: An isolated private network within AWS that houses all our deployed infrastructure, giving us control over what is publicly accessible, what is kept private, and how resources communicate with each other.

- **Subnets**: Used to subdivide the VPC and segment resources into different network zones. We utilise two public subnets and two private subnets, each spanning separate AZs. This allows us to minimise exposure for each resource (e.g. RDS is placed in a private subnet as it should never be directly reachable from the internet) and enables high availability by spreading resources across multiple AZs.

- **ALB (Application Load Balancer)**: A load balancer that sits across both public subnets spanning each AZ, acting as a single entry point for incoming traffic and distributing it across our ECS tasks allowing for horizontal scaling and high availability.

- **Route53**: AWS's DNS (Domain Name System) Service used to translate the domain name of the application to the IP address of the ALB. This means users can use a human friendly readable domain name to access the application and we do not have to worry if the ALB IP address changes. 


### Data
- **RDS (Relational Database Service)**: AWS's managed SQL database service. It is the logical choice as the legacy platform uses a  Microsoft SQL Server database and this would be the most seamless AWS alterntive allowing for all existing functionality in the application to work as expected. This managed service is prefered vs self hosting the database on EC2 as AWS manages backups, patching, and Multi-AZ failover and it is simpler to set up and migrate to. Additionally, the primary RDS database will synchronously replicate its data to a standby RDS database (which we can failover to) in a different subnet and AZ for resilience and high availability.


### Observability
- **CloudWatch**: Used to monitor and alert on metrics and logs for our AWS deployed application. Where possible - each resource would export their logs and metrics to CloudWatch. This will give us insight into the application and allow for quicker recovery and more effective instance tuning / scaling. Dashboards and alerts would also be set up on key metrics - allowing for quicker and more proactive incident response.

- **X-Ray**: Used to monitor distributed traces across our services, allowing us to identify latency bottlenecks and optimise performance. ServiceLens can be used to integrate X-Ray traces directly into CloudWatch for unified observability.


### Post MVP
- We utilise two AZs in the MVP to demonstrate high availability in a concise manner — however this can be generalised to three AZs to maximise resilience when considering a production deployment.
- When productionizing this application a cost benifit analysis should be done to consider if the time / money spent in the management of the EC2 servers is worth it and if spending extra on a serverless solution such as fargate may be a better option.
- If greater performance and scalability is required post-MVP, migrating to Aurora should be considered — noting that this would require moving away from SQL Server to MySQL or PostgreSQL.



## Data Migration: 
In terms of the overall migration we will migrate the application to ECS first while keeping it pointed at the existing database, then migrate the database separately using DMS once the application layer is stable — minimising risk by changing one thing at a time.

For the data migration itself we will use AWS DMS (Database Migration Service) to migrate the data from the legacy SQL Server database to RDS. The migration will be performed in the following steps:

1. **Provision RDS**: Set up the RDS SQL Server instance in the private subnets as per the architecture diagram.

2. **Configure DMS**: Set up a DMS replication instance and configure the source (legacy SQL Server) and target (RDS) endpoints.

3. **Full Load**: DMS performs an initial full copy of all existing data from the legacy database to RDS.

4. **CDC (Change Data Capture)**: While the full load is running, DMS continuously captures any new changes on the source database so no data is lost during migration.

5. **Validate**: Once the full load is complete and CDC is in sync, we validate the data in RDS matches the source database.

6. **Cutover**: Re-point the ECS application layer to RDS and decommission the legacy database. CDC ensures both databases remain in sync up until cutover, minimising downtime.



## Security
### Services Used
- **ACM (Certificate Manager)**: Provides the SSL/TLS certificate that the ALB uses to handle HTTPS traffic on port 443 from users.

- **Secrets Manager**: Stores sensitive credentials and configurations such as DB passwords and connection information so they are never hardcoded.

- **Security Groups**: ALB, ECS and RDS each have separate least-privilege Security Groups e.g. ALB only accepts inbound on ports 80/443, ECS only accepts traffic from the ALB on port 8080, and RDS only accepts traffic from ECS on port 1433.

- **IAM (Identity and Access Management)**: Least-privilege IAM roles will be assigned to each service e.g. the ECS task role will only have permissions to pull images from ECR, read secrets from Secrets Manager, and write logs to CloudWatch.


### Post MVP
- For the MVP we are using public subnets for the ECS tasks. This was done for cost and simplicity reasons. However for production we would move the ECS tasks to private subnets behind a NAT Gateway for additional security (ensuring nothing external can initiate direct connection).


## CI/CD Pipeline:
### Tools
- **GitHub Actions**
- **Terraform**
- **ECR**

### Pipelines
- **CI/Build Pipeline**
- **CD/Deploy Pipeline**

