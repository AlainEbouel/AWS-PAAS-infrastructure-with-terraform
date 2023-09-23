locals {
  region = "ca-central-1"
  env    = "dev"
  private_subnets = {
    "subnet1"={"name" = "public-subnet-1", "cidr_block" = "10.0.1.0/24", "AZ" = "ca-central-1a"},
    # "subnet2"={"name" = "public-subnet-2", "cidr_block" = "10.0.2.0/24", "AZ" = "ca-central-1b"},
  }
  public_subnets = {
    "subnet1" = { "name" = "private-subnet-1", "cidr_block" = "10.0.3.0/24", "AZ" = "ca-central-1b" }
  }
}

provider "aws" {
  region = local.region
}

module "aws-infra" {
  source = "../../modules/aws"
  env = local.env
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets
}
# resource "aws_dynamodb_table" "terraform-state-lock" {
#   name = "terraform-state-lock-dynamo"
#   hash_key = "LockID"
#   read_capacity = 1
#   write_capacity = 1
 
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }