# Projeto CI/CD com Terraform e Docker

Projeto completo de infraestrutura como código (IaC) usando Terraform, com pipeline CI/CD automatizado via GitHub Actions para deploy de aplicação Docker em AWS EC2.

## 📋 Índice

- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Configuração Inicial](#configuração-inicial)
- [Como Usar](#como-usar)
- [Pipeline CI/CD](#pipeline-cicd)
- [Custos Estimados](#custos-estimados)

## 🏗️ Arquitetura

O projeto cria automaticamente:

- **Bucket S3** - Armazenamento remoto dos estados do Terraform
- **DynamoDB** - Controle de lock para evitar conflitos
- **EC2 Instance** - Servidor web com Docker
- **Security Group** - Regras de firewall (SSH e HTTP)
- **GitHub Actions** - Pipeline automatizado de deploy

## 🛠️ Tecnologias

- **Terraform** - Infraestrutura como código
- **AWS** - Provedor de nuvem
- **Docker** - Containerização da aplicação
- **GitHub Actions** - CI/CD
- **Nginx** - Servidor web

## 📁 Estrutura do Projeto

```
projeto-cicd/
├── App/
│   ├── Dockerfile
│   └── index.html
├── Terraform/
│   ├── bootstrap/          # Bootstrap da infraestrutura base
│   │   └── main.tf        # Cria bucket S3 e tabela DynamoDB
│   ├── backend.tf         # Configuração do backend remoto
│   ├── main.tf            # Provider AWS
│   ├── ec2.tf             # Instância EC2
│   ├── security-group.tf  # Regras de firewall
│   └── outputs.tf         # Outputs (IP, etc)
└── .github/
    └── workflows/
        └── deploy.yml     # Pipeline CI/CD
```

## ✅ Pré-requisitos

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- Conta AWS com credenciais configuradas
- Conta no [Docker Hub](https://hub.docker.com/)
- Repositório no GitHub

## 🚀 Configuração Inicial

### 1. Bootstrap da Infraestrutura Base

O bootstrap cria o bucket S3 e a tabela DynamoDB necessários para o backend remoto do Terraform.

**Execute apenas UMA VEZ:**

```bash
cd Terraform/bootstrap
terraform init
terraform apply
```

**Recursos criados:**
- Bucket S3: `terraform-state-projeto-cicd-{ACCOUNT_ID}`
- Tabela DynamoDB: `terraform-locks`

**Importante:** O estado do bootstrap fica armazenado localmente em `bootstrap/terraform.tfstate`. Guarde esse arquivo!

### 2. Configurar Secrets no GitHub

Acesse: `Settings > Secrets and variables > Actions`

Adicione os seguintes secrets:

```
AWS_ACCESS_KEY_ID          # Chave de acesso AWS
AWS_SECRET_ACCESS_KEY      # Secret key AWS
DOCKERHUB_USERNAME         # Usuário do Docker Hub
DOCKERHUB_TOKEN            # Token do Docker Hub
EC2_SSH_PRIVATE_KEY        # Chave privada SSH para EC2
```

### 3. Criar Key Pair na AWS

```bash
aws ec2 create-key-pair \
  --key-name projeto-cicd-key \
  --query 'KeyMaterial' \
  --output text > projeto-cicd-key.pem

chmod 400 projeto-cicd-key.pem
```

Adicione o conteúdo da chave privada no secret `EC2_SSH_PRIVATE_KEY`.

## 💻 Como Usar

### Deploy Local

```bash
cd Terraform
terraform init      # Inicializa e configura o backend remoto
terraform plan      # Visualiza mudanças
terraform apply     # Cria infraestrutura
```

### Deploy via GitHub Actions

1. Faça commit das suas alterações:
```bash
git add .
git commit -m "Atualização da infraestrutura"
git push origin main
```

2. O GitHub Actions será acionado automaticamente e irá:
   - ✅ Provisionar infraestrutura com Terraform
   - ✅ Construir imagem Docker
   - ✅ Fazer push para Docker Hub
   - ✅ Fazer deploy na EC2
   - ✅ Verificar se a aplicação está rodando

### Acessar a Aplicação

Após o deploy, acesse:
```
http://{IP_DA_EC2}
```

O IP será exibido nos outputs do Terraform e nos logs do GitHub Actions.

### Destruir Infraestrutura

```bash
cd Terraform
terraform destroy
```

**Para destruir o bootstrap também:**
```bash
cd Terraform/bootstrap
terraform destroy
```

## 🔄 Pipeline CI/CD

O pipeline é executado automaticamente em cada push para a branch `main` e segue estas etapas:

1. **Terraform** - Provisiona/atualiza infraestrutura
2. **Build** - Cria imagem Docker da aplicação
3. **Deploy** - Deploy da aplicação na EC2
4. **Verify** - Testa se a aplicação está acessível

## 💰 Custos Estimados

### Free Tier (primeiros 12 meses)
- EC2 t2.micro: **750 horas/mês grátis**
- S3: **5GB grátis**
- DynamoDB: **25GB grátis**

### Após Free Tier
- EC2 t2.micro: ~$8-10/mês
- S3: ~$0.01/mês (poucos KB)
- DynamoDB: ~$0.01/mês (baixo uso)
- **Total: ~$8-10/mês**

**Dica:** Execute `terraform destroy` quando não estiver usando para evitar custos.

## 📝 Notas Importantes

### Backend Remoto

- O estado do Terraform é armazenado no S3
- Lock automático via DynamoDB previne conflitos
- Versionamento habilitado para recuperação
- Criptografia AES256 ativada

### Segurança

- Bucket S3 com acesso público bloqueado
- Security Group permite apenas SSH (22) e HTTP (80)
- Credenciais armazenadas como GitHub Secrets
- Chaves SSH nunca commitadas no repositório

### Próximos Projetos

Para criar novos projetos usando o mesmo backend:

```terraform
terraform {
  backend "s3" {
    bucket         = "terraform-state-projeto-cicd-264765155565"
    key            = "novo-projeto/terraform.tfstate"  # Mude apenas isso
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.

## ✨ Autor

**João Pedro**

---

⭐ Se este projeto foi útil, deixe uma estrela!
