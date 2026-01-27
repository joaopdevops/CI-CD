terraform {
  backend "s3" {
    bucket         = "terraform-state-projeto-cicd-264765155565"
    key            = "projeto-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
