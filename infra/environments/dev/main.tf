terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "terraform-admin"
  region  = "eu-north-1"
}

module "network" {
  source   = "../../modules/network"
  name     = "dev"
  vpc_cidr = "10.1.0.0/16"

  public_subnets = {
    "eu-north-1a" = "10.1.1.0/24"
    # "eu-north-1b" = "10.1.2.0/24"
  }

  app_subnets = {
    "eu-north-1a" = "10.1.11.0/24"
    # "eu-north-1b" = "10.1.12.0/24"
  }
}

module "app" {
  source                    = "../../modules/app"
  name                      = "dev"
  public_subnet_ids         = module.network.public_ids
  app_subnet_ids            = module.network.app_ids
  backend_security_group_id = module.network.backend_security_group_id
  webapp_security_group_id  = module.network.webapp_security_group_id
  api_container_name        = "markusryoti/terraform-aws-api-demo:latest"
}
