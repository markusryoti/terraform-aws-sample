variable "name" { type = string }

variable "public_subnet_ids" {
  type = map(string)
}

variable "app_subnet_ids" {
  type = map(string)
}

variable "backend_security_group_id" {
  type = string
}

variable "webapp_security_group_id" {
  type = string
}

variable "api_container_name" {
  type = string
}
