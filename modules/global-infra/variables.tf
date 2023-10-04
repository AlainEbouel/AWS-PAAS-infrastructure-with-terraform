variable "env" {
  type = string
}

variable "aws-account" {
  type = string
}

variable "region" {
  type = string
}

variable "private-subnets" {
  type    = map(map(string))
  default = {}
}

variable "vpc-cidr" {
  type = string
}

variable "module-name" {
  type = string
}

variable "eks-cluster-security_group" {
  type = string
}

variable "eks-cluster-vpc" {
  type = string
}

variable "eks-cluster-node-group-role" {
  type = string
}

variable "final_snapshot_identifier" {
  type = string
  default = ""
}

variable "ecr-repos" {
  type = map(map(string))
  default = {}  
}