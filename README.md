# Terraform-3Tier-Project
## 3-Tier Architecture Deployment on AWS using Terraform

##  Project Description

This project demonstrates the implementation of a **secure, scalable, and production-ready 3-tier architecture** on Amazon Web Services (AWS) using **Terraform (Infrastructure as Code)**.

The goal of this project is to automate the provisioning of cloud infrastructure by following industry best practices such as:

- Network isolation using VPC  
- Layered architecture (Web, Application, Database)  
- Secure communication between tiers  
- Remote state management using S3  

---

##  Architecture Overview

The infrastructure is divided into three logical layers:

### 1. Web Tier (Presentation Layer)

- Deployed in **Public Subnet**
- Contains EC2 instance acting as Web Server
- Accepts HTTP traffic from users

### 2. Application Tier (Business Logic Layer)

- Deployed in **Private Subnet**
- Contains EC2 instance running application logic
- Accessible only from Web Tier

### 3. Database Tier (Data Layer)

- Deployed using **Amazon RDS (MySQL)**
- Placed in **Private Subnets**
- Accessible only from Application Tier

---

## Architecture Flow
```
User → Web Server (Public Subnet)
↓
Application Server (Private Subnet)
↓
RDS MySQL Database (Private Subnet)
```


---

## Technologies & Services Used

- **Terraform** – Infrastructure as Code tool  
- **AWS VPC** – Virtual private cloud  
- **AWS EC2** – Virtual servers  
- **AWS RDS (MySQL)** – Managed database service  
- **AWS S3** – Backend for Terraform state storage  
- **Security Groups** – Firewall rules  

---

## Project Structure
```
3-tier-terraform-project/
│
├── main.tf # Core infrastructure configuration
├── variables.tf # Input variables
├── outputs.tf # Output values
├── README.md # Documentation
```

---

## Prerequisites

Before running this project, ensure you have:

- AWS Account (Free Tier recommended)  
- IAM User with programmatic access  
- Terraform installed (v1.x or later)  
- AWS CLI configured (`aws configure`)  
- Key Pair created in AWS  

---

##  Terraform Backend Configuration

Terraform state is stored remotely in an S3 bucket.

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-3tier-infrastructure"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```
![](./img/Screenshot%202026-03-19%20111122.png)


## Networking Configuration

###  VPC
- CIDR Block: `10.0.0.0/16`
- Provides isolated network environment

### Subnets
- 1 Public Subnet (Web Tier)
- 2 Private Subnets (App + DB Tier)

### Internet Gateway
- Enables internet access for public subnet

### Route Table
- Routes internet traffic via Internet Gateway

---

## Security Implementation

Security is enforced using **separate Security Groups for each layer**:

### Web Tier Security Group
- Allows HTTP (Port 80) from anywhere (`0.0.0.0/0`)

###  Application Tier Security Group
- Allows traffic only from Web Tier (Port 8080)

###  Database Tier Security Group
- Allows MySQL (Port 3306) only from Application Tier

### Key Security Principle
> Least Privilege Access Each tier can communicate only with the required layer

---

## Compute Layer

### Web Server (EC2)
- Deployed in Public Subnet
- Accessible via public IP
- Handles incoming user requests

### Application Server (EC2)
- Deployed in Private Subnet
- No direct internet access
- Processes application logic

---

## Database Layer (RDS)

- Engine: MySQL
- Instance Type: `db.t3.micro`
- Deployed in private subnets
- Secured using DB Security Group

---

## Deployment Steps

### Step 1: Initialize Terraform
```bash
terraform init
```
![](./img/Screenshot%202026-03-19%20143646.png)
### Step 2: Validate Configuration
```
terraform validate
```
### Step 3: Preview Infrastructure
```
terraform plan
```
![](./img/Screenshot%202026-03-19%20143657.png)
### Step 4: Deploy Infrastructure
```
terraform apply
```
![](./img/Screenshot%202026-03-19%20150240.png)


### Terraform Apply Output

Below screenshot shows successful execution of `terraform apply`:

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
```

### EC2 Instances Created

- Web Server (Public EC2)

- Application Server (Private EC2)

![](./img/Screenshot%202026-03-19%20144248.png)

### RDS Database Created

- MySQL RDS instance successfully provisioned

- Status: Available

- Endpoint generated

![](./img/Screenshot%202026-03-19%20144338.png)

### S3 Backend (Terraform State)

- Remote state file stored in S3 bucket

![](./img/Screenshot%202026-03-19%20144321.png)

---

## Cleanup Resources (Terraform Destroy)

To avoid unnecessary AWS charges, all resources created using Terraform were properly destroyed after testing.

###  Destroy Command

```bash
terraform destroy
```
