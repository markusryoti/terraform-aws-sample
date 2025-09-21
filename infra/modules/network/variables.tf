variable "name" { type = string }

variable "vpc_cidr" { type = string }

variable "public_subnets" {
  type = map(string) # AZ => CIDR
}

variable "app_subnets" {
  type = map(string)
}
