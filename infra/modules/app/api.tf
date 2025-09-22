resource "aws_instance" "api" {
  for_each               = var.app_subnet_ids
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.nano"
  subnet_id              = each.value
  vpc_security_group_ids = [var.backend_security_group_id]

  user_data = <<-EOL
    #!/bin/bash
    set -ex

    sudo apt-get -y update
    sudo apt-get -y install ca-certificates curl gnupg lsb-release

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get -y update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    until sudo docker info >/dev/null 2>&1; do
      echo "Waiting for Docker to start..."
      sleep 5
    done

    sudo docker run -d -p 8080:8080 --name myapp ${var.api_container_name}

    EOL

  tags = {
    Name = "${var.name}-api-${each.key}"
  }
}
