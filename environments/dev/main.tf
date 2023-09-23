locals {
  region      = "ca-central-1"
}

provider "aws" {
  region = local.region
}

module "aws-infra" {
  source = "../../modules/aws"
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