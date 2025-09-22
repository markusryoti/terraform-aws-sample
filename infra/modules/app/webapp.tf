locals {
  nginx_conf = templatefile("${path.module}/templates/nginx.conf.tpl", {
    backend_ips = [for inst in aws_instance.api : inst.private_ip]
  })
}

resource "aws_instance" "web" {
  for_each               = var.public_subnet_ids
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.nano"
  subnet_id              = each.value
  vpc_security_group_ids = [var.webapp_security_group_id]

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
