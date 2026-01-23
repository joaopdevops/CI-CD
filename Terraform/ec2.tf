resource "aws_instance" "web_server" {
  ami           = "ami-0e2c8caa4b6378d8c" # Ubuntu 22.04 LTS us-east-1
  instance_type = "t2.micro"              # Free tier
  key_name      = "projeto-cicd-key"      # Nome da sua Key Pair

  # Associa o Security Group criado
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Script que roda quando a VM inicializa
  user_data = <<-EOF
    #!/bin/bash
    # Atualiza pacotes
    apt-get update
    
    # Instala Docker
    apt-get install -y docker.io
    
    # Inicia Docker agora
    systemctl start docker
    
    # Configura Docker para iniciar no boot
    systemctl enable docker
    
    # Permite usar docker sem sudo
    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "projeto-cicd-web-server"
  }
}