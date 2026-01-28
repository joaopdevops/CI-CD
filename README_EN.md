# CI/CD Project with Terraform and Docker

Complete Infrastructure as Code (IaC) project using Terraform, with automated CI/CD pipeline via GitHub Actions for deploying a Docker application to AWS EC2.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Technologies](#technologies)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [How to Use](#how-to-use)
- [CI/CD Pipeline](#cicd-pipeline)
- [Estimated Costs](#estimated-costs)
- [Security Notes](#security-notes)

## 🏗️ Architecture

The project automatically creates:

- **S3 Bucket** - Remote storage for Terraform state
- **DynamoDB** - Lock control to prevent conflicts
- **EC2 Instance** - Web server with Docker
- **Security Group** - Firewall rules (SSH and HTTP)
- **GitHub Actions** - Automated deployment pipeline

## 🛠️ Technologies

- **Terraform** - Infrastructure as Code
- **AWS** - Cloud provider
- **Docker** - Application containerization
- **GitHub Actions** - CI/CD
- **Nginx** - Web server

## 📁 Project Structure

```
projeto-cicd/
├── App/
│   ├── Dockerfile
│   └── index.html
├── Terraform/
│   ├── bootstrap/          # Base infrastructure bootstrap
│   │   └── main.tf        # Creates S3 bucket and DynamoDB table
│   ├── backend.tf         # Remote backend configuration
│   ├── main.tf            # AWS Provider
│   ├── ec2.tf             # EC2 Instance
│   ├── security-group.tf  # Firewall rules
│   └── outputs.tf         # Outputs (IP, etc)
└── .github/
    └── workflows/
        └── deploy.yml     # CI/CD Pipeline
```

## ✅ Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS account with configured credentials
- [Docker Hub](https://hub.docker.com/) account
- GitHub repository

## 🚀 Initial Setup

### 1. Base Infrastructure Bootstrap

The bootstrap creates the S3 bucket and DynamoDB table required for Terraform's remote backend.

**Execute ONLY ONCE:**

```bash
cd Terraform/bootstrap
terraform init
terraform apply
```

**Created resources:**
- S3 Bucket: `terraform-state-projeto-cicd-{ACCOUNT_ID}`
- DynamoDB Table: `terraform-locks`

**Important:** Bootstrap state is stored locally in `bootstrap/terraform.tfstate`. Keep this file safe!

### 2. Configure GitHub Secrets

Go to: `Settings > Secrets and variables > Actions`

Add the following secrets:

```
AWS_ACCESS_KEY_ID          # AWS access key
AWS_SECRET_ACCESS_KEY      # AWS secret key
DOCKERHUB_USERNAME         # Docker Hub username
DOCKERHUB_TOKEN            # Docker Hub token
EC2_SSH_PRIVATE_KEY        # SSH private key for EC2
```

### 3. Create Key Pair on AWS

```bash
aws ec2 create-key-pair \
  --key-name projeto-cicd-key \
  --query 'KeyMaterial' \
  --output text > projeto-cicd-key.pem

chmod 400 projeto-cicd-key.pem
```

Add the private key content to the `EC2_SSH_PRIVATE_KEY` secret.

## 💻 How to Use

### Local Deploy

```bash
cd Terraform
terraform init      # Initialize and configure remote backend
terraform plan      # Preview changes
terraform apply     # Create infrastructure
```

### Deploy via GitHub Actions

1. Commit your changes:
```bash
git add .
git commit -m "Infrastructure update"
git push origin main
```

2. GitHub Actions will automatically:
   - ✅ Provision infrastructure with Terraform
   - ✅ Build Docker image
   - ✅ Push to Docker Hub
   - ✅ Deploy to EC2
   - ✅ Verify application is running

### Access the Application

After deployment, access:
```
http://{EC2_IP}
```

The IP will be displayed in Terraform outputs and GitHub Actions logs.

### Destroy Infrastructure

```bash
cd Terraform
terraform destroy
```

**To also destroy bootstrap:**
```bash
cd Terraform/bootstrap
terraform destroy
```

## 🔄 CI/CD Pipeline

The pipeline runs automatically on every push to the `main` branch and follows these steps:

1. **Terraform** - Provision/update infrastructure
2. **Build** - Create Docker image of application
3. **Deploy** - Deploy application to EC2
4. **Verify** - Test if application is accessible

## 💰 Estimated Costs

### Free Tier (first 12 months)
- EC2 t2.micro: **750 hours/month free**
- S3: **5GB free**
- DynamoDB: **25GB free**

### After Free Tier
- EC2 t2.micro: ~$8-10/month
- S3: ~$0.01/month (few KB)
- DynamoDB: ~$0.01/month (low usage)
- **Total: ~$8-10/month**

**Tip:** Run `terraform destroy` when not in use to avoid costs.

## ⚠️ Security Notes

This project was built for educational purposes using disposable infrastructure.

Some configurations (such as SSH access open to 0.0.0.0/0 and explicit resource names) were intentionally kept simple to focus on learning Terraform, AWS networking, Docker, and CI/CD pipelines.

In a production environment, these settings would be hardened by:
- Restricting SSH access to specific IPs or using AWS SSM Session Manager
- Using fully parameterized resource names
- Applying IAM least privilege policies
- Using AWS Secrets Manager for credentials
- Implementing WAF and rate limiting
- Setting up CloudWatch monitoring and alerts

## 📝 Important Notes

### Remote Backend

- Terraform state is stored in S3
- Automatic locking via DynamoDB prevents conflicts
- Versioning enabled for recovery
- AES256 encryption enabled

### Security

- S3 bucket with public access blocked
- Security Group allows only SSH (22) and HTTP (80)
- Credentials stored as GitHub Secrets
- SSH keys never committed to repository

### Next Projects

To create new projects using the same backend:

```terraform
terraform {
  backend "s3" {
    bucket         = "terraform-state-projeto-cicd-264765155565"
    key            = "new-project/terraform.tfstate"  # Change only this
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 🤝 Contributing

1. Fork the project
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is under the MIT license.

## 👨‍💻 Author

**João Pedro**

---

⭐ If this project was useful, leave a star!
