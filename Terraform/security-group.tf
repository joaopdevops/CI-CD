resource "aws_security_group" "web_sg" {
  name        = "projeto-cicd-sg"
  description = "Security group para projeto CI/CD"

  # Permite SSH (porta 22)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # De qualquer IP
  }

  # Permite HTTP (porta 80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # De qualquer IP
  }

  # Permite toda saída
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Todos os protocolos
    cidr_blocks = ["0.0.0.0/0"] # Para qualquer destino
  }

  tags = {
    Name = "projeto-cicd-security-group"
  }
}