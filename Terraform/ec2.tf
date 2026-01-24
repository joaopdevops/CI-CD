resource "aws_instance" "web_server" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  key_name      = "projeto-cicd-key"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
EOF

  tags = {
    Name = "projeto-cicd-web-server"
  }
}
