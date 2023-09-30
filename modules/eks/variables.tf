variable "env" {
  type = string
}

variable "public-subnets" {
  type    = map(map(string))
  default = {}
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

variable "aws-account" {
  type = string
}
