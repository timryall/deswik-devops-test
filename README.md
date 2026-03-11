# Deswik Take Home DevOps Test
I have assumed that these are two completely separate challenges and thus the implementation challenge does not use the design from the design challenge.


## Part 1: Design Challenge
Please see design.md for details.

## Part 2: Implementation Challenge
### Overview of Design


### Deployment Steps
#### Stage One - AWS and Terraform Set Up
1. Create an AWS account if you don't have one
2. Install and configure the AWS CLI (aws configure with your access key/secret)
3. Install Terraform
4. Create an S3 bucket + DynamoDB table for Terraform remote state (so state is stored safely, not locally)



#### Tooling versions confirmed as working
- Terraform == v1.14.6
- aws-cli == v2.34.6
- Python == v3.13.12