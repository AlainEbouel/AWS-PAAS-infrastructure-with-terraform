variable "env" {
  type = string
}

variable "private_subnets" {
  type    = map(map(string))
  default = {}
}

variable "vpc-cidr" {
  type = string
}

variable "module-name" {
  type = string
}