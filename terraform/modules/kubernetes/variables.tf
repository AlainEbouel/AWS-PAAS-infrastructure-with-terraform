# variable "module-name" {
#   type = string
# }

variable "env" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks-node-group-name" {
  type = string
}
variable "service-name" {
  type = string
}

variable "enable-service" {
  type = bool
  default = false
}