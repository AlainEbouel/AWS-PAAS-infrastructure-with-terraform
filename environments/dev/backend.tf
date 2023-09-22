terraform {
  backend "s3" {
    bucket = "my-terraform-states-001"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
