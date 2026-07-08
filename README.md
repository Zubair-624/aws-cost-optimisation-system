# 🛡️CostGuard - AWS Cost Optimisation System 🛡️

> **Automated AWS cost governance platform** with anomaly detection, rightsizing recommendations, and Slack/email alerting - built with Terraform, Python (boto3), and Grafana dashboards.

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python_3.11-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-In_Progress-orange?style=for-the-badge)

---

## 📌 Table of Contents

- [Problem Statement](#-problem-statement)
- [What CostGuard Does](#-what-costguard-does)
- [Key Features](#key-features)
- [Why This Project Matters](#why-this-project-matters)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Phase Progress](#-phase-progress)
- [Phase 1 - Bootstrap](#-phase-1--project-bootstrap-completed)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Author](#-author)

---

## 💡 Problem Statement

Cloud costs are one of the **biggest pain points** for any engineering team working on AWS.

The problem is not that AWS is expensive - the problem is **visibility**. Most teams only discover a cost spike when the monthly invoice arrives. By then, the damage is already done. An engineer accidentally left a NAT Gateway running, a Lambda function started getting called millions of times due to a bug, or an RDS instance was over-provisioned from day one, and nobody noticed for six months.

**CostGuard solves this by:**
- Automatically collecting daily spend data across all AWS services
- Detecting anomalies when any service spikes beyond a threshold
- Recommending EC2 rightsizing based on actual CPU usage
- Sending instant Slack and email alerts when budgets are exceeded

---

## 🎯 What CostGuard Does

CostGuard is a **fully automated cost governance platform** that runs silently in the background every single day. You deploy it once, and it takes care of everything from that point forward.

Here is exactly what happens every day at 6:00 AM UTC without any human involvement:

**Step 1 - Data Collection**
A Lambda function wakes up and calls the AWS Cost Explorer API. It pulls the last 30 days of spending data broken down by every AWS service - EC2, RDS, Lambda, S3, CloudFront, and so on. Every record gets written into DynamoDB with a timestamp, and a full raw JSON report gets saved to S3 for audit purposes.

**Step 2 - Anomaly Detection**
A second Lambda function reads the last 7 days of data from DynamoDB and calculates a rolling average for each service. It then compares today's spend against that average. If any service has jumped more than 20% above its normal baseline, CostGuard flags it as an anomaly and records it.

**Step 3 - Rightsizing Analysis**
A third Lambda function looks at your EC2 instances through two lenses - AWS Trusted Advisor's low utilisation check, and actual CloudWatch CPU metrics over the past 14 days. Any instance averaging below 10% CPU is identified as a candidate for downsizing, along with an estimated monthly saving if you moved it one size down.

**Step 4 - Smart Alerting**
A fourth Lambda function reads all the anomalies and rightsizing recommendations from DynamoDB, builds a clean summary message, and publishes it to an SNS topic. From there, it fans out - one path goes directly to your email, another path triggers a Slack relay Lambda that posts the message to your Slack channel via a webhook.

**Step 5 - Budget Guardrails**
Separately, AWS Budgets is configured with your monthly spend limit. The moment your actual spend crosses 80% of that limit, an alert fires immediately - without waiting for the daily pipeline to run. If forecasted spend looks like it will exceed 100%, another alert goes out proactively.

**Step 6 - Visual Dashboard**
A Grafana dashboard connected to CloudWatch shows daily spend trends, anomaly events, budget utilisation, and Lambda health - all in one place.

---

## 🔑 Key Features

- **Zero manual work** - everything runs on a daily schedule automatically
- **Anomaly detection** - catches unexpected cost spikes before they become big bills
- **Rightsizing recommendations** - tells you exactly which EC2 instances are wasting money and by how much
- **Dual alerting** - both Slack and email so nothing gets missed
- **Budget guardrails** - immediate alerts at 80% spend, proactive alerts at 100% forecast
- **Full audit trail** - every daily cost report is stored in S3 in a structured folder hierarchy
- **Infrastructure as Code** - the entire platform is provisioned with Terraform, so it can be deployed to any AWS account in minutes
- **Least-privilege security** - every Lambda function has only the exact IAM permissions it needs, nothing more
- **No hardcoded credentials** - secrets are stored in AWS SSM Parameter Store, CI/CD uses OIDC role assumption
- **Grafana dashboards** - visual cost trends and anomaly history without logging into the AWS Console

---

## 🧠 Why This Project Matters

Most portfolio projects show that someone can spin up an EC2 instance or deploy a containerised app. CostGuard demonstrates something more valuable - the ability to **think about cloud infrastructure like a senior engineer**.

It covers:

- **FinOps** - the practice of financial accountability in cloud environments, which is one of the fastest-growing disciplines in DevOps right now
- **Event-driven architecture** - Lambda functions chained together via EventBridge, each with a single responsibility
- **Production-quality Python** - real boto3 usage with pagination, error handling, retries, and structured logging, not just tutorial-level scripts
- **Terraform module design** - eight separate modules, each independently testable and reusable, following the same patterns used in professional infrastructure codebases
- **Observability** - CloudWatch alarms, log groups, custom metrics, and Grafana dashboards working together
- **Security discipline** - IAM least-privilege, SSM for secrets, encrypted S3 state, public access blocked everywhere

This is not a toy project. It solves a problem that engineering managers and DevOps leads deal with every week.

---

## 🏗️ Architecture

> 📸 **[Screenshot placeholder - add `docs/architecture.png` here]**

```
EventBridge Scheduler (daily 06:00 UTC)
        │
        ▼
Lambda: cost-collector
  → Cost Explorer API (last 30 days)
  → Stores per-service spend in DynamoDB
  → Stores raw JSON report in S3
        │
        ▼
Lambda: anomaly-detector          Lambda: rightsizing-advisor
  → 7-day rolling average           → Trusted Advisor + CloudWatch
  → Flags spikes > 20%              → Identifies underused EC2
  → Writes to DynamoDB              → Writes to DynamoDB
        │                                   │
        └──────────────┬────────────────────┘
                       ▼
              Lambda: notifier
                → Reads anomalies + recommendations
                → Publishes to SNS topic
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
    Email (SNS)            Lambda: slack-relay
                             → SSM Parameter Store
                             → Slack Webhook

  AWS Budgets (separate flow)
    → 80% / 100% threshold alerts
    → SNS → Email + Slack

  Grafana Dashboard
    → CloudWatch custom metrics datasource
    → Daily cost, anomalies, budget utilisation
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **IaC** | Terraform >= 1.6 (AWS provider ~> 5.0) |
| **Language** | Python 3.11 + boto3 |
| **Compute** | AWS Lambda |
| **Scheduling** | Amazon EventBridge Scheduler |
| **Database** | Amazon DynamoDB (3 tables) |
| **Storage** | Amazon S3 |
| **Alerting** | Amazon SNS → Email + Slack |
| **Cost APIs** | AWS Cost Explorer, AWS Budgets, Trusted Advisor |
| **Observability** | CloudWatch Metrics + Logs + Alarms |
| **Dashboards** | Grafana (CloudWatch datasource) |
| **CI/CD** | GitHub Actions (OIDC - no static credentials) |
| **Secrets** | AWS SSM Parameter Store |
| **Testing** | pytest + moto (AWS mock library) |

---

## 📁 Project Structure

```
aws-cost-optimisation-system/
│
├── .github/workflows/
│   ├── terraform-plan.yml        # Runs on PR
│   └── terraform-apply.yml       # Runs on merge to main
│
├── terraform/
│   ├── backend.tf                # S3 remote state + DynamoDB lock
│   ├── providers.tf              # AWS provider + default tags
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── modules/
│       ├── dynamodb/             # 3 tables: cost_data, anomalies, recommendations
│       ├── s3/                   # Reports bucket
│       ├── iam/                  # Least-privilege roles + policies
│       ├── lambda/               # All 5 Lambda functions
│       ├── eventbridge/          # Daily cron scheduler
│       ├── sns/                  # Alerts topic + subscriptions
│       ├── budgets/              # Monthly budget alarms
│       └── cloudwatch/           # Alarms + log groups + dashboard
│
├── lambdas/
│   ├── cost_collector/
│   ├── anomaly_detector/
│   ├── rightsizing_advisor/
│   ├── notifier/
│   └── slack_relay/
│
├── scripts/
│   ├── bootstrap_backend.sh      # One-time: creates S3 + DynamoDB for TF state
│   ├── package_lambdas.sh
│   └── run_tests.sh
│
├── grafana/dashboards/
│   └── costguard-overview.json
│
├── docs/
│   └── architecture.png
│
└── README.md
```
---

## 🔗 Terraform Version

This project uses **Terraform v1.10.5**

<details>
<summary>How to install Terraform v1.10.5 on WSL / Ubuntu</summary>

### Step 1 - Check if already installed

```bash
terraform version
```

If you see `Terraform v1.10.5` you are good to go.
If not - follow the steps below.

### Step 2 - Install

```bash
sudo apt update && sudo apt install -y gnupg software-properties-common curl
```

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash
sudo apt update
sudo apt install terraform=1.10.5-1
```

### Step 3 - Verify

```bash
terraform version
```

Expected output:
```bash
Terraform v1.10.5
on linux_amd64
```

</details>

---

## ✅ Phase Progress

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 1** | Project Bootstrap | ✅ Complete |
| **Phase 2** | DynamoDB + S3 Modules | 🔄 In Progress |
| **Phase 3** | IAM Module | ⬜ Pending |
| **Phase 4** | Lambda Functions (Python) | ⬜ Pending |
| **Phase 5** | EventBridge + SNS Modules | ⬜ Pending |
| **Phase 6** | Budgets + CloudWatch + Grafana | ⬜ Pending |
| **Phase 7** | CI/CD + Tests + Documentation | ⬜ Pending |

---

## 🚀 Phase 1 - Project Bootstrap ✅ Completed

### What was built

| Resource | Name | Purpose |
|----------|------|---------|
| **S3 Bucket** | `zubair-tf-state-project002` | Stores Terraform remote state |
| **DynamoDB Table** | `terraform-state-lock-project002` | Prevents concurrent Terraform runs |
| **Terraform Backend** | S3 + DynamoDB | Remote state with locking enabled |
| **AWS Provider** | `hashicorp/aws v5.100.0` | Pinned via `.terraform.lock.hcl` |

### S3 Bucket configuration

| Setting | Value |
|---------|-------|
| Versioning | ✅ Enabled |
| Public Access | ✅ Fully blocked (all 4 flags) |
| Encryption | ✅ SSE-S3 (AES256) |
| Region | `us-east-1` |

### DynamoDB Table configuration

| Setting | Value |
|---------|-------|
| Partition Key | `LockID` (String) |
| Billing Mode | `PAY_PER_REQUEST` |
| Table Status | `ACTIVE` |

### Verification

> 📸 **[Screenshot placeholder - add your terminal output here showing `terraform init` success]**

```bash
# Commands used to verify
aws s3api head-bucket --bucket zubair-tf-state-project002 --profile zubair-devops
aws s3api get-bucket-versioning --bucket zubair-tf-state-project002 --profile zubair-devops
aws s3api get-public-access-block --bucket zubair-tf-state-project002 --profile zubair-devops
aws dynamodb describe-table --table-name terraform-state-lock-project002 --region us-east-1 --profile zubair-devops
```

**Result:** `Successfully configured the backend "s3"` ✅

---

## 🔧 Prerequisites

- AWS Account with programmatic access
- AWS CLI configured (`aws configure --profile zubair-devops`)
- Terraform >= 1.6 installed
- Python 3.11 installed
- `direnv` installed (for automatic env loading via `.envrc`)

---

## ⚡ Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/aws-cost-optimisation-system.git
cd aws-cost-optimisation-system
```

### 2. Bootstrap the Terraform backend (run once only)

```bash
bash scripts/bootstrap_backend.sh
```

### 3. Initialise Terraform

```bash
cd terraform
terraform init
```

### 4. Set up Python environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install boto3 pytest black flake8 moto
```

---

## 👤 Author

**Zubair Mazumder**
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- LinkedIn: [your-linkedin](https://linkedin.com/in/your-linkedin)

---

> 🚧 *This project is actively being built. Each phase is committed separately with full documentation.*
