locals {
  nginx_conf = templatefile("${path.module}/templates/nginx.conf.tpl", {
    backend_ip = aws_instance.api.private_ip
  })
}

resource "aws_instance" "web" {
  ami             = "ami-0a716d3f3b16d290c"
  instance_type   = "t3.nano"
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]

  user_data = <<-EOF
        #!/bin/bash
        set -e

        sudo apt update -y
        sudo apt install -y nginx

        cat > proxy.conf <<'NGINX'
        ${local.nginx_conf}
        NGINX

        sudo mv proxy.conf /etc/nginx/conf.d/reverse-proxy.conf

        sudo rm /etc/nginx/sites-enabled/default

        sudo systemctl enable nginx
        sudo systemctl restart nginx
    EOF

  tags = {
    Name = "web-app"
  }
}
