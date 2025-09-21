terraform {
  backend "s3" {
    bucket       = "markusryoti-demo-terraform-state-bucket"
    key          = "state/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
    profile      = "terraform-admin"
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "markusryoti-demo-terraform-state-bucket"
  region = "eu-north-1"
}
