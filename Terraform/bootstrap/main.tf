# Bootstrap - Cria infraestrutura base para Terraform Remote State
# Execute apenas UMA VEZ: terraform init && terraform apply
# Para outros projetos: Reutilize o mesmo bucket, mude apenas a "key" no backend.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# S3 Bucket - Armazena o state do Terraform (arquivo .tfstate)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-projeto-cicd-264765155565" # Nome único global (inclui Account ID)

  tags = {
    Name    = "Terraform State Bucket"
    Project = "projeto-cicd"
  }
}

# Versionamento - Mantém histórico do state para rollback
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia - Protege dados sensíveis no state
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Criptografia padrão AWS
    }
  }
}

# Bloqueia acesso público - Segurança
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB - Controla lock do state (evita conflitos)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks" # Nome fixo (Terraform procura esse)
  billing_mode = "PAY_PER_REQUEST" # Paga apenas quando usar
  hash_key     = "LockID"          # Chave primária para identificar locks

  attribute {
    name = "LockID"
    type = "S" # String
  }

  tags = {
    Name    = "Terraform State Lock Table"
    Project = "projeto-cicd"
  }
}

# ============================================
# COMO USAR EM OUTROS PROJETOS:
# ============================================
# 1. Mantenha o mesmo bucket e tabela DynamoDB
# 2. No backend.tf do novo projeto, mude apenas:
#
# terraform {
#   backend "s3" {
#     bucket = "terraform-state-projeto-cicd-264765155565"  # MESMO bucket
#     key    = "novo-projeto/terraform.tfstate"             # MUDE AQUI
#     ...
#   }
# }
#
# Isso permite múltiplos projetos usando a mesma infraestrutura base!
