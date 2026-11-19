# AWS 3-Tier Web Application Infrastructure

A cloud infrastructure project built with **Terraform, AWS, Docker, Packer and Python**. The project demonstrates how to deploy a containerized Flask application on AWS using a three-tier architecture with a private EC2 instance and a private PostgreSQL database.

The infrastructure is designed with a focus on network isolation, IAM-based authentication, least-privilege access and cost optimization.

## Architecture

![AWS Architecture](docs/architecture.png)

### Architecture Overview

The infrastructure consists of three main layers:

| Layer | AWS Service | Description |
|---|---|---|
| Presentation | Application Load Balancer | Public entry point for incoming HTTP traffic |
| Application | EC2 + Docker | Private EC2 instance running a containerized Flask application |
| Database | Amazon RDS PostgreSQL | Private PostgreSQL database with IAM authentication |

### Request Flow

1. A user sends an HTTP request to the Application Load Balancer.
2. The ALB forwards the request to the EC2 instance in a private subnet.
3. The Flask application processes the request inside a Docker container.
4. When database access is required, the application connects to Amazon RDS PostgreSQL using IAM Database Authentication.
5. The response is returned through the ALB to the user.

## Infrastructure

### Networking

The infrastructure is deployed in the AWS Frankfurt region (`eu-central-1`).

- Custom VPC with CIDR `10.0.0.0/16`.
- Two public subnets across two Availability Zones.
- Two private application subnets.
- Two private database subnets.
- Internet Gateway for public subnet connectivity.
- Separate route tables for public, application and database subnets.
- No NAT Gateway.

Three VPC interface endpoints provide Systems Manager connectivity without requiring a NAT Gateway:

- `ssm`
- `ssmmessages`
- `ec2messages`

The endpoints are deployed in the first application subnet.

### Application Layer

The application runs on an EC2 `t3.micro` instance in a private subnet.

Technologies:

- Ubuntu 22.04
- Docker
- Python 3.12
- Flask
- Gunicorn
- Psycopg 3

The Docker image is built using a custom AMI created with HashiCorp Packer.

A systemd service automatically starts the application container after the EC2 instance boots.

### Database Layer

The database uses Amazon RDS PostgreSQL.

Configuration:

- PostgreSQL
- `db.t3.micro`
- 20 GB gp3 storage
- Storage encryption enabled
- Private database subnets
- Public accessibility disabled
- IAM Database Authentication enabled

The application connects to PostgreSQL using temporary IAM authentication tokens generated through the AWS SDK for Python (`boto3`).

The RDS master credentials are managed by AWS Secrets Manager.

## Security

The project implements several AWS security practices:

- EC2 instance deployed without a public IP address.
- RDS database deployed in private subnets.
- Security groups configured with explicit least-privilege access rules.
- ALB accepts incoming HTTP traffic on port 80.
- Application accepts traffic on port 5000 only from the ALB security group.
- PostgreSQL accepts traffic on port 5432 only from the application security group.
- EC2 administration through AWS Systems Manager Session Manager.
- IAM roles used instead of long-term AWS credentials on EC2.
- IAM Database Authentication used for application-to-database connections.
- IMDSv2 enforced on the EC2 instance.

**Security limitation:** The Application Load Balancer uses HTTP only. HTTPS, TLS certificates and a custom domain were not configured because this project focuses on demonstrating AWS infrastructure and application connectivity rather than providing a production-ready public service.

## Infrastructure as Code

Terraform is used to provision and manage the AWS infrastructure.

The configuration defines:

- VPC and subnet resources.
- Internet Gateway and route tables.
- Security groups and network rules.
- VPC interface endpoints.
- EC2 instance and IAM resources.
- Application Load Balancer and target group.
- RDS PostgreSQL instance.

The infrastructure can be provisioned and removed using Terraform commands.

## Custom AMI with Packer

HashiCorp Packer is used to build a custom Amazon Machine Image.

The image contains the application environment and Docker configuration required to run the Flask application.

This approach allows EC2 instances to start with the application environment already prepared instead of requiring all dependencies to be installed during instance startup.

## Application Endpoints

The Flask application exposes the following endpoints:

| Endpoint | Description |
|---|---|
| `/` | Main application page |
| `/health` | Application health check |
| `/db-health` | Database connectivity check |

The ALB uses `/health` as its target group health check endpoint.

The `/db-health` endpoint verifies connectivity between the application and PostgreSQL.

## Cost Optimization

Cost optimization was considered during the infrastructure design.

- No NAT Gateway was deployed.
- Private instances use VPC endpoints for Systems Manager connectivity.
- EC2 and RDS use small instance types.
- Infrastructure is intended to be deployed for testing and demonstration purposes.
- Terraform can destroy the infrastructure when it is no longer needed.

AWS resources such as EC2, RDS, ALB, EBS storage, VPC endpoints and AMI snapshots may incur charges while they exist. Always verify that unused resources have been removed.

## Deployment

### Prerequisites

- AWS account
- AWS CLI configured with appropriate permissions
- Terraform
- HashiCorp Packer
- Docker
- Access to the project repository

### 1. Build the Application AMI

Use Packer to build the custom application AMI from the Packer template included in the repository.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the Configuration

```bash
terraform fmt -check -recursive
terraform validate
```

### 4. Review the Deployment Plan

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Review the proposed changes before confirming deployment.

### 6. Initialize the Database Application User

After RDS becomes available, execute `scripts/init-db.sql` using an administrative PostgreSQL connection.

This creates the application database user, grants the `rds_iam` role and configures database permissions.

### 7. Verify the Application

Use the DNS name of the Application Load Balancer to access the application.

Test the following endpoints:

```text
http://<ALB-DNS>/
http://<ALB-DNS>/health
http://<ALB-DNS>/db-health
```

### 8. Destroy the Infrastructure

When testing is complete, remove the Terraform-managed resources:

```bash
terraform destroy
```

The custom AMI and its associated snapshots created by Packer must be removed separately if they are no longer needed.

## Project Screenshots

Screenshots documenting the deployed infrastructure and application are available in:

```text
docs/screenshots/
```

They demonstrate the custom AMI, VPC networking, private EC2 instance, load balancer, PostgreSQL database, Systems Manager access and application health checks.

## Skills Demonstrated

- AWS cloud infrastructure
- Infrastructure as Code with Terraform
- Custom AMI creation with Packer
- Docker containerization
- Python and Flask application deployment
- AWS VPC networking
- Public and private subnet architecture
- Application Load Balancer configuration
- Amazon RDS PostgreSQL
- IAM roles and policies
- IAM Database Authentication
- AWS Systems Manager
- AWS Secrets Manager
- Security group design
- Cloud cost optimization

## Author

**Jakub Lewiński**

GitHub: [jakub-lewinski-dev](https://github.com/jakub-lewinski-dev)