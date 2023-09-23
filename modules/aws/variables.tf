variable "env" {
  type = string
}

variable "public_subnets" {
  type = map(map(string))
  default = {}
}

variable "private_subnets" {
  type = map(map(string))
  default = {}
}