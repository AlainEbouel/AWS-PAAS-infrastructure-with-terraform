locals {
  region      = "ca-central-1"
}

provider "aws" {
  region = local.region
}

module "aws-infra" {
  source = "../../modules/aws"
}