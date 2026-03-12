# Deswik Take Home DevOps Test
I have assumed that these are two completely separate challenges and thus the implementation challenge does not use the design from the design challenge.


# Part 1: Design Challenge
Please see design.md for details.

# Part 2: Implementation Challenge
A minimal containerised Hello World web application deployed to AWS ECS Fargate with a full CI/CD pipeline using GitHub Actions and Terraform.

## High Level Architecture
![MVP Final High Level Architecture](./imgs/p2_architecture_diagram.png)

## Making Changes
All changes follow the same workflow — open a PR to main, the CI pipeline will validate and build your changes - then on merge the CD pipeline will deploy them.

### 1. Create a new branch
After cloning the repo to your local environment run:

```bash
git checkout -b your-branch-name
```

### 2. Make your changes

| Type of change | Files to edit |
|---|---|
| App code | `app/server.js` |
| Container | `app/Dockerfile` |
| Infrastructure | `terraform/*.tf` |
| CI/CD Pipelines | `.github/workflows/deploy.yml` |

### 3. Push and open a PR

```bash
git add .
git commit -m "your commit message"
git push origin your-branch-name
```

Then open a PR on GitHub targeting `main`. Please aim to use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). 

### 4. CI pipeline runs automatically

On every PR the following checks run:
- Dockerfile lint
- Node.js syntax check
- Docker build and push to ECR
- Terraform fmt, validate and plan

Fix any failures before merging.

### 5. Merge to deploy

Once CI is green, merge the PR. The CD pipeline will automatically:
1. Run terraform apply
2. Force a new ECS deployment to pull the latest Docker image

### 6. Verify

Wait 2-3 minutes for the new ECS task to start, then verify:

```bash
curl http://<alb_dns_name>
```

The ALB DNS name can be found via:
- The terraform outputs: `terraform output alb_dns_name` (see terraform apply step of CD pipeline run)
- AWS Console: **EC2 → Load Balancers → deswik-alb → DNS name**


## Observability

| Resource | Where to find it |
|---|---|
| CloudWatch Dashboard | AWS Console → CloudWatch → Dashboards → deswik-dashboard |
| Container Logs | AWS Console → CloudWatch → Log Groups → /ecs/deswik-app |
| VPC Flow Logs | AWS Console → CloudWatch → Log Groups → /vpc/deswik-flow-logs |
| CPU Alarm | AWS Console → CloudWatch → Alarms → deswik-ecs-cpu-high |
| GuardDuty Findings | AWS Console → GuardDuty → Findings |
