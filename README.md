# AWS Infrastructure Portfolio (Terraform)

This project provisions a secure, scalable, and modular AWS cloud infrastructure using **Terraform**. It defines a complete multi-tier architecture containing custom networking, compute instances, relational databases, security groups, and load balancer target configurations.

---

## 🏗️ Architecture & Component Overview

The infrastructure has been successfully deployed and verified in the **AWS Frankfurt (`eu-central-1`)** region. Below is a detailed breakdown of each provisioned component:

### 1. Networking & VPC (`Creating-VPC.png`)
A dedicated Virtual Private Cloud (VPC) provides complete network isolation. The workflow automatically provisions public and private subnets, an Internet Gateway, Route Tables, an Elastic IP, and a NAT Gateway to ensure secure outbound internet access for private workloads while maintaining secure public routing.

- **Status:** Successfully Created (`vpc-0db00ae9e6c1fb7dd`)[cite: 11]
- **Key Features:** DNS Hostnames & DNS Resolution enabled[cite: 11].

<p align="center">
  <img src="Creating-VPC.png" alt="VPC Creation Workflow" width="800">
</p>

---

### 2. Security Groups (`Creating-Securtity-Group.png`)
Stateful virtual firewalls control inbound and outbound traffic for the resources. The web security group is configured to allow secure administrative access via SSH (`Port 22`) and standard web traffic via HTTP (`Port 80`).

- **Security Group ID:** `sg-00e88da1789cdfdc3` (`web-security-group`)[cite: 9]
- **Inbound Rules:**
  - **SSH (Port 22):** Restricted access[cite: 9]
  - **HTTP (Port 80):** Open to the world (`0.0.0.0/0`)[cite: 9]

<p align="center">
  <img src="Creating-Securtity-Group.png" alt="Security Group Configuration" width="800">
</p>

---

### 3. Compute Instance - EC2 (`Creating-EC2-Instance.png`)
An Amazon EC2 instance serves as the core web server node. It utilizes an Ubuntu AMI and the cost-effective `t3.micro` instance type (fully eligible for the AWS Free Tier), deployed directly into the public subnet.

- **Instance ID:** `i-022778c7f041d6bf0` (`my-portfolio-server`)[cite: 8]
- **Instance Type:** `t3.micro` in Availability Zone `eu-central-1a`[cite: 8]
- **State:** Running & Initializing[cite: 8]

<p align="center">
  <img src="Creating-EC2-Instance.png" alt="EC2 Instance Running" width="800">
</p>

---

### 4. Relational Database - Amazon RDS (`Creating-Database.png`)
A managed PostgreSQL relational database instance (`my-portfolio-db`) provides robust backend data persistence with automated backups, high availability, and secure engine version handling.

- **DB Identifier:** `my-portfolio-db`[cite: 7]
- **Engine:** PostgreSQL (Instance size: `db.t3.micro`)[cite: 7]
- **Status:** Available[cite: 7]

<p align="center">
  <img src="Creating-Database.png" alt="RDS Database Creation" width="800">
</p>

---

### 5. Load Balancing - Target Group (`Creating-Target-Group.png`)
A Target Group (`my-portfolio-tg`) routes incoming web traffic to registered EC2 instances using HTTP protocol on port 80, ensuring readiness for an Application Load Balancer integration.

- **Target Group Name:** `my-portfolio-tg`[cite: 10]
- **Target Type:** Instance (`i-022778c7f041d6bf0`)[cite: 10]
- **Protocol:** HTTP:80[cite: 10]

<p align="center">
  <img src="Creating-Target-Group.png" alt="Target Group Setup" width="800">
</p>

---

## 🚀 Getting Started & Deployment

To deploy this infrastructure yourself:

1. Clone the repository:
   ```bash
   git clone [https://github.com/your-username/your-repo.git](https://github.com/your-username/your-repo.git)
   cd your-repo