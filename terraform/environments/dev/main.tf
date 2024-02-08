locals {
  region      = "ca-central-1"
  env         = "dev"
  aws-account = "244586165116"

  eks-module = {
    module-name = "eks-cluster"
    vpc-cidr    = "10.0.0.0/16"
    private-subnets = {
      "subnet1" = { "name" = "private-1", "cidr_block" = "10.0.0.0/24", "AZ" = "ca-central-1a" },
      "subnet2" = { "name" = "private-2", "cidr_block" = "10.0.1.0/24", "AZ" = "ca-central-1b" }
    }
    public-subnets = {
      "subnet1" = { "name" = "public-1", "cidr_block" = "10.0.2.0/24", "AZ" = "ca-central-1a" }
      "subnet2" = { "name" = "public-2", "cidr_block" = "10.0.3.0/24", "AZ" = "ca-central-1b" }
    }
  }

  global-infra-module = {
    module-name = "global-infra"
    vpc-cidr    = "192.168.0.0/16"
    private-subnets = {
      "subnet1" = { "name" = "private-1", "cidr_block" = "192.168.1.0/24", "AZ" = "ca-central-1a" },
      "subnet2" = { "name" = "private-2", "cidr_block" = "192.168.2.0/24", "AZ" = "ca-central-1b" },
      # "subnet3"={"name" = "private-3", "cidr_block" = "192.168.3.0/24", "AZ" = "ca-central-1d"},
    }
    ecr-repos = {
      shopping-Portal = { name = "shopping-portal", mutability = "MUTABLE", scan_on_push = true }
    }
  }
  # kubernetes-module = {
  #   module-name = "kubernetes"
  # }

  k8s-services = {
    jenkins = {
      enable = false
    }
    pack_broker = {
      enable = true
      service-name = "packbroker"
    }
  }

  microsoft-ad ={
    vpc-cidr    = "10.0.0.0/16"
    private-subnets = {
      "subnet1" = { "name" = "private-1", "cidr_block" = "10.0.0.0/24", "AZ" = "ca-central-1a" },
      "subnet2" = { "name" = "private-2", "cidr_block" = "10.0.1.0/24", "AZ" = "ca-central-1b" }
    }
    module-name = "microsoft-ad"
  }

}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}
module "microsoft-ad" {
  source = "../../modules/microsoft-ad"
  env             = local.env
  region          = local.region
  aws-account     = local.aws-account
  private-subnets = local.microsoft-ad.private-subnets
  vpc-cidr        = local.microsoft-ad.vpc-cidr
  module-name     = local.eks-module.module-name
}

module "eks" {
  source          = "../../modules/eks"
  module-name     = local.eks-module.module-name
  env             = local.env
  region          = local.region
  aws-account     = local.aws-account
  public-subnets  = local.eks-module.public-subnets
  private-subnets = local.eks-module.private-subnets
  vpc-cidr        = local.eks-module.vpc-cidr
}

# module "global-infra" {
#   source                      = "../../modules/global-infra"
#   region                      = local.region
#   aws-account                 = local.aws-account
#   module-name                 = local.global-infra-module.module-name
#   env                         = local.env
#   private-subnets             = local.global-infra-module.private-subnets
#   vpc-cidr                    = local.global-infra-module.vpc-cidr
#   eks-cluster-security_group  = can(module.eks.eks-cluster-security_groups) ? module.eks.eks-cluster-security_groups : ""
#   eks-cluster-vpc             = module.eks.eks-cluster-vpc
#   eks-cluster-node-group-role = can(module.eks.eks-cluster-node-group-role) ? module.eks.eks-cluster-node-group-role : ""
#   ecr-repos                   = local.global-infra-module.ecr-repos
# }

# module "shopping-portal" {
#   source               = "../../modules/shopping-portal"
#   module-name          = local.eks-module.module-name
#   env                  = local.env
#   eks_ca_cert          = module.eks.eks_ca_cert
#   eks_cluster_endpoint = module.eks.eks-cluster-endpoint
#   eks_cluster_name     = module.eks.eks_cluster_name
# }

module "kubernetes" {
  for_each = { for k,v in local.k8s-services : k => v if v.enable }
  source           = "../../modules/kubernetes"
  eks_cluster_name = module.eks.eks_cluster_name
  # module-name      = local.kubernetes.module-name
  env              = local.env
  eks-node-group-name = module.eks.eks-node-group-name
  service-name = each.value.enable ? each.value.service-name : ""
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