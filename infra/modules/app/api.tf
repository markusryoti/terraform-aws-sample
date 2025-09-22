resource "aws_instance" "api" {
  for_each               = var.app_subnet_ids
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.nano"
  subnet_id              = each.value
  vpc_security_group_ids = [var.backend_security_group_id]

  user_data = <<-EOL
    #!/bin/bash
    set -ex

    sudo apt update -y
    sudo apt install -y docker.io

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo docker run -d -p 8080:8080 --name myapp ${var.api_container_name}

    EOL

  tags = {
    Name = "${var.name}-api-${each.key}"
  }
}
