terraform {
  backend "s3" {
    bucket = "my-terraform-states-001"
    key    = "dev/terraform.tfstate"
    region = "ca-central-1"
  }
}
