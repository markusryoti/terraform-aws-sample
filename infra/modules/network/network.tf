# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name}-public-${each.key}-subnet" }
}

# Private Subnets
resource "aws_subnet" "app" {
  for_each          = var.app_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = { Name = "${var.name}-app-${each.key}-subnet" }
}

# Public Route Table
resource "aws_route_table" "public" {
  for_each = var.public_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-${each.key}-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

# NAT Gateway for private subnet
resource "aws_eip" "nat" {
  domain = "vpc"
}

# resource "aws_nat_gateway" "nat" {
#   for_each      = var.app_subnets
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.app[each.key].id

#   tags = {
#     Name = "${var.name}-${each.key}-nat"
#   }
# }

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id # place in first public subnet

  tags = {
    Name = "${var.name}-nat"
  }
}

# Private Route Table
# resource "aws_route_table" "private" {
#   for_each = var.app_subnets
#   vpc_id   = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat[each.key].id
#   }

#   tags = {
#     Name = "${var.name}-${each.key}-private-rt"
#   }
# }

resource "aws_route_table" "private" {
  for_each = var.app_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.name}-${each.key}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.app_subnets
  subnet_id      = aws_subnet.app[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# resource "aws_route_table_association" "private" {
#   for_each       = var.app_subnets
#   subnet_id      = aws_subnet.app[each.key].id
#   route_table_id = aws_route_table.public[each.key].id
# }

# Security Groups
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  name   = "web-sg"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id
  name   = "backend-sg"

  ingress {
    description     = "Allow traffic from web app"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_id" { value = aws_vpc.main.id }
output "public_ids" {
  value = { for k, s in aws_subnet.public : k => s.id }
}
output "app_ids" {
  value = { for k, s in aws_subnet.app : k => s.id }
}
output "webapp_security_group_id" { value = aws_security_group.web_sg.id }
output "backend_security_group_id" { value = aws_security_group.backend_sg.id }
