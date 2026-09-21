# Complete Project & Execution Guide: Terraform Multi-Environment Infrastructure ("CloudStore")

This document contains everything needed to understand, execute, demonstrate, and explain this project.

---

## Table of Contents
1. [Project Overview & Use Case](#1-project-overview--use-case)
2. [Candidate Checklist & Rubric Mapping](#2-candidate-checklist--rubric-mapping)
3. [Repository File Map](#3-repository-file-map)
4. [The 4 Evaluator Verification Commands](#4-the-4-evaluator-verification-commands)
5. [Complete Step-by-Step Execution Workflow](#5-complete-step-by-step-execution-workflow)
   - [Phase 1: Setup & Initialization](#phase-1-setup--initialization)
   - [Phase 2: Code Validation & Quality Checks](#phase-2-code-validation--quality-checks)
   - [Phase 3: Deploying the 'dev' Environment](#phase-3-deploying-the-dev-environment)
   - [Phase 4: Deploying the 'prod' Environment](#phase-4-deploying-the-prod-environment)
   - [Phase 5: Destruction & Cost Cleanup](#phase-5-destruction--cost-cleanup)
6. [AWS Console Visual Verification Checklist](#6-aws-console-visual-verification-checklist)
7. [Architecture & Code Breakdown](#7-architecture--code-breakdown)
8. [Word-for-Word Presentation Script](#8-word-for-word-presentation-script)
9. [Frequently Asked Questions & Troubleshooting](#9-frequently-asked-questions--troubleshooting)

---

## 1. Project Overview & Use Case

### The Use Case: "CloudStore" E-Commerce Platform
We built a resilient, decoupled web tier and asset storage backend for an e-commerce platform called **CloudStore**, deployed across two strictly isolated environments in a single AWS account using **Terraform Workspaces**:

* **Development Environment (`dev`)**:
  * **Objective:** Cost optimization for rapid testing and prototyping.
  * **EC2:** 1 instance of `t3.micro` (free-tier eligible / cheap).
  * **Storage:** 20 GB gp3 encrypted volume.
  * **Monitoring:** Basic CloudWatch monitoring (`enable_detailed_monitoring = false`).
  * **S3:** Unversioned asset bucket (`Suspended`).

* **Production Environment (`prod`)**:
  * **Objective:** High availability, fault tolerance, and durability.
  * **EC2:** 3 instances of `t3.small` distributed across **multiple Availability Zones** via modulo index balancing.
  * **Storage:** 50 GB gp3 encrypted volume per instance.
  * **Monitoring:** Detailed 1-minute CloudWatch monitoring enabled.
  * **S3:** Encrypted and **Versioned** asset bucket (`Enabled`) to protect against accidental data deletion.

---

## 2. Candidate Checklist & Rubric Mapping

All evaluation criteria from the challenge rubric have been fully satisfied:

| # | Checklist Item | Evaluation Requirement | Status | Project Evidence |
|---|---|---|:---:|---|
| 1 | **2 Workspaces** | `dev` & `prod` with isolated state | ✅ **Pass** | `.terraform.tfstate.d/dev/` and `.terraform.tfstate.d/prod/` |
| 2 | **5+ Variables** | Defined in `variables.tf` | ✅ **Pass** | 7 typed variables with validations |
| 3 | **Different .tfvars** | `terraform.tfvars.dev` & `.prod` | ✅ **Pass** | Distinct instance types, counts, and monitoring settings |
| 4 | **3+ Data Blocks** | No hardcoded VPC, Subnet, AMI IDs | ✅ **Pass** | 5 data blocks in `main.tf` (`grep -c "^data " main.tf` = 5) |
| 5 | **No Hardcoded IDs** | 0 static `vpc-`, `subnet-`, `ami-` | ✅ **Pass** | All network and OS resources queried dynamically |
| 6 | **Dev Smaller Than Prod** | Dev: `t3.micro`, Prod: `t3.small` | ✅ **Pass** | Configured in respective `.tfvars` files |
| 7 | **Instance Counts** | Dev: 1 instance, Prod: 3 instances | ✅ **Pass** | Dynamically handled via `count = var.instance_count` |
| 8 | **Consistent Tagging** | Tags include environment name | ✅ **Pass** | All resources tagged with `Environment`, `Workspace`, `ManagedBy` |
| 9 | **terraform validate** | Must pass cleanly | ✅ **Pass** | Returns `Success! The configuration is valid.` |
| 10 | **Switch & Apply Both** | Ability to apply both workspaces | ✅ **Pass** | Verified with active AWS credentials |

---

## 3. Repository File Map

```
devops-mse1/
│
├── terraform.tf            # Terraform & AWS provider setup, region, default tags
├── variables.tf            # 7 variable declarations with validation logic
├── main.tf                 # 5 Data blocks + Security Group, EC2 Cluster, S3 Bucket
├── outputs.tf              # Informative deployment outputs (IDs, IPs, subnets)
│
├── terraform.tfvars.dev    # Dev environment parameter values
├── terraform.tfvars.prod   # Prod environment parameter values
│
├── demo_evaluation.ps1     # Automated test script running the 4 eval commands
├── README.md               # Project overview and instructions
└── EXECUTION_GUIDE.md      # This complete master execution guide
```

---

## 4. The 4 Evaluator Verification Commands

These are the exact commands the evaluator will run or ask you to run:

### Command 1: Workspace Verification
```bash
terraform workspace list
```
**Output:**
```text
  default
* dev
  prod
```
*Key takeaway: Proves both `dev` and `prod` workspaces exist.*

---

### Command 2: Syntax and Configuration Validation
```bash
terraform validate
```
**Output:**
```text
Success! The configuration is valid.
```
*Key takeaway: Confirms syntax, variable references, and provider constraints are 100% correct.*

---

### Command 3: Data Blocks Check (Zero Hardcoding)
```bash
grep -c "^data " main.tf
```
*(On Windows PowerShell, you can run the same command directly since Git grep is installed, or run `(Select-String -Pattern "^data " -Path main.tf).Count`)*
**Output:**
```text
5
```
*Key takeaway: Confirms you have 5 data blocks (requirement was 3+).*

---

### Command 4: Dry-Run Plan for Dev & Prod
```bash
# View Dev configuration plan
terraform workspace select dev
terraform plan -var-file="terraform.tfvars.dev"

# View Prod configuration plan
terraform workspace select prod
terraform plan -var-file="terraform.tfvars.prod"
```
*Key takeaway: Shows `Plan: 5 to add` for Dev and `Plan: 7 to add` for Prod without applying.*

---

## 5. Complete Step-by-Step Execution Workflow

Follow these exact steps from start to finish:

### Phase 1: Setup & Initialization
If working on a new machine:
```powershell
# 1. Ensure AWS CLI credentials are configured
aws configure
# (Input Access Key, Secret Key, Region: ap-south-1, Output: json)

# 2. Verify AWS connection
aws sts get-caller-identity

# 3. Initialize Terraform providers and backend
terraform init
```

---

### Phase 2: Code Validation & Quality Checks
```powershell
# Check formatting
terraform fmt -check

# Validate configuration
terraform validate

# Run the automated runner script
powershell -ExecutionPolicy Bypass -File .\demo_evaluation.ps1
```

---

### Phase 3: Deploying the 'dev' Environment
```powershell
# 1. Switch to the dev workspace
terraform workspace select dev

# 2. Review the plan
terraform plan -var-file="terraform.tfvars.dev"

# 3. Apply the changes
terraform apply -var-file="terraform.tfvars.dev"
# Type 'yes' when prompted
```

**Expected Results in Dev:**
* **1 EC2 instance** (`t3.micro`) created.
* **1 Security Group** (`cloudstore-dev-web-sg`) created.
* **1 S3 bucket** (`cloudstore-dev-<account-id>-assets`) created.
* **S3 Versioning:** Suspended.

---

### Phase 4: Deploying the 'prod' Environment
```powershell
# 1. Switch to the prod workspace
terraform workspace select prod

# 2. Review the plan
terraform plan -var-file="terraform.tfvars.prod"

# 3. Apply the changes
terraform apply -var-file="terraform.tfvars.prod"
# Type 'yes' when prompted
```

**Expected Results in Prod:**
* **3 EC2 instances** (`t3.small`) created and distributed across different subnets.
* **Detailed CloudWatch monitoring:** Enabled.
* **50 GB encrypted root disk** per instance.
* **1 S3 bucket** (`cloudstore-prod-<account-id>-assets`) created.
* **S3 Versioning:** Enabled.

---

### Phase 5: Destruction & Cost Cleanup (⚠️ Important)
Once the demo/evaluation is finished, always tear down the resources to avoid incurring charges:

```powershell
# Destroy Dev infrastructure
terraform workspace select dev
terraform destroy -var-file="terraform.tfvars.dev"
# Type 'yes' when prompted

# Destroy Prod infrastructure
terraform workspace select prod
terraform destroy -var-file="terraform.tfvars.prod"
# Type 'yes' when prompted
```

---

## 6. AWS Console Visual Verification Checklist

When presenting in the **AWS Management Console (Region: ap-south-1 Mumbai)**:

### 1. EC2 Instances (`EC2 > Instances`)
* [ ] Click on the search bar $\rightarrow$ filter by `Tag: Environment = dev`
  * Confirm **1 instance** running of type `t3.micro`.
* [ ] Clear filter $\rightarrow$ filter by `Tag: Environment = prod`
  * Confirm **3 instances** running of type `t3.small`.
  * Point out the **Availability Zone** column: the instances are distributed across `ap-south-1a`, `ap-south-1b`, and `ap-south-1c`.

### 2. S3 Buckets (`S3 > Buckets`)
* [ ] Find `cloudstore-dev-<account_id>-assets`:
  * Click **Properties** $\rightarrow$ show **Bucket Versioning: Suspended**.
* [ ] Find `cloudstore-prod-<account_id>-assets`:
  * Click **Properties** $\rightarrow$ show **Bucket Versioning: Enabled**.

### 3. Security Groups (`EC2 > Security Groups`)
* [ ] View `cloudstore-dev-web-sg` and `cloudstore-prod-web-sg`.
* [ ] Show Inbound Rules: HTTP (Port 80) open to `0.0.0.0/0`, SSH (Port 22) restricted.

---

## 7. Architecture & Code Breakdown

### Why are Data Blocks Essential?
Hardcoding IDs like `ami-066c4849e6b3a1e3d` or `vpc-032b2629fa98794e0` causes:
1. **Portability failure:** The code will crash if deployed in another AWS account or another region (`us-east-1`).
2. **Maintenance burden:** AMIs are constantly patched and retired by AWS.

By using dynamic `data` blocks:
```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
```
Terraform automatically queries the live AWS account during planning and retrieves the current, valid IDs on the fly!

### Multi-AZ Distribution Logic
To balance production instances evenly across all available subnets:
```hcl
subnet_id = element(data.aws_subnets.default.ids, count.index % length(data.aws_subnets.default.ids))
```
If there are 3 subnets:
* Instance 1 (index 0) $\rightarrow$ Subnet 0 (`ap-south-1a`)
* Instance 2 (index 1) $\rightarrow$ Subnet 1 (`ap-south-1b`)
* Instance 3 (index 2) $\rightarrow$ Subnet 2 (`ap-south-1c`)

---

## 8. Word-for-Word Presentation Script

Use this script during your evaluation:

> **"Good morning/afternoon. Today I am demonstrating a production-grade multi-environment infrastructure on AWS managed with Terraform."**
> 
> *(Run: `terraform workspace list`)*
> **"Instead of duplicating code or using multiple repositories, we use Terraform Workspaces to maintain complete state isolation within a single AWS account. As you can see, we have isolated `dev` and `prod` workspaces."**
> 
> *(Run: `grep -c "^data " main.tf`)*
> **"One of the critical rules of Infrastructure as Code is zero hardcoding. In `main.tf`, we have 5 dynamic data blocks that query the AWS API at runtime for the VPC, subnets, availability zones, and latest Amazon Linux 2023 AMI."**
> 
> *(Run: `terraform validate`)*
> **"Our configuration is completely validated and adheres to HashiCorp best practices."**
> 
> *(Show `terraform.tfvars.dev` and `terraform.tfvars.prod`)*
> **"Our environments are differentiated by workload requirements. In `dev`, we optimize for cost with 1 `t3.micro` instance and unversioned storage. In `prod`, we provision 3 `t3.small` instances distributed across separate availability zones with detailed CloudWatch monitoring and versioned, encrypted S3 storage."**
> 
> *(If applying live or showing AWS Console)*
> **"As shown in the AWS Console, all resources were created with uniform tags for governance, without a single manual click. Thank you!"**

---

## 9. Frequently Asked Questions & Troubleshooting

#### Q: How does Terraform separate dev and prod state files?
**A:** When using workspaces, Terraform automatically creates a directory called `terraform.tfstate.d/<workspace_name>/terraform.tfstate`. Each workspace has its own independent state file, preventing conflicts.

#### Q: What happens if I switch workspaces?
**A:** Running `terraform workspace select <name>` changes the active workspace pointer. Any subsequent `plan`, `apply`, or `destroy` command operates strictly on that workspace's resources.

#### Q: Why are my S3 bucket names unique?
**A:** S3 bucket names are globally unique across all AWS accounts. We dynamically construct the bucket name using `${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}-assets`. Because your AWS Account ID is globally unique, the bucket name is guaranteed never to conflict.
