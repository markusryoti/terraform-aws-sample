resource "aws_instance" "api" {
  ami             = "ami-0a716d3f3b16d290c"
  instance_type   = "t3.nano"
  subnet_id       = aws_subnet.private.id
  security_groups = [aws_security_group.backend_sg.id]

  user_data = <<-EOL
    #!/bin/bash
    set -ex

    sudo apt update -y
    sudo apt install -y docker.io

    sudo systemctl enable docker
    sudo systemctl start docker

    # Run your container (replace nginx:latest with your image)
    sudo docker run -d -p 8080:8080 --name myapp ${local.api_container_name}

    EOL

  tags = {
    Name = "api"
  }
}
