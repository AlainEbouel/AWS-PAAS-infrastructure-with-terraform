locals {
  region = "ca-central-1"
  env    = "dev"

  eks-module = {
    module-name = "eks-cluster"
    vpc-cidr = "10.0.0.0/16"
    private_subnets = {
      "subnet1"={"name" = "public-subnet-1", "cidr_block" = "10.0.0.0/24", "AZ" = "ca-central-1a"},
      # "subnet2"={"name" = "public-subnet-2", "cidr_block" = "10.0.2.0/24", "AZ" = "ca-central-1b"},
    }
    public_subnets = {
      "subnet1" = { "name" = "private-subnet-1", "cidr_block" = "10.0.1.0/24", "AZ" = "ca-central-1b" }
    }
  }

  global-infra-module = {
    module-name = "global-infra"
    vpc-cidr = "10.0.0.0/16"
    private_subnets = {
      "subnet1"={"name" = "public-subnet-1", "cidr_block" = "10.0.0.0/24", "AZ" = "ca-central-1d"},
    }
  }
}

provider "aws" {
  region = local.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "eks" {
  source = "../../modules/eks"
  module-name = local.eks-module.module-name
  env = local.env
  public_subnets = local.eks-module.public_subnets
  private_subnets = local.eks-module.private_subnets
  vpc-cidr = local.eks-module.vpc-cidr
}

module "global-infra" {
  source = "../../modules/global-infra"
  module-name = local.global-infra-module.module-name
  env = local.env
  private_subnets = local.eks-module.private_subnets
  vpc-cidr = local.global-infra.vpc-cidr
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