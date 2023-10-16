variable "module-name" {
  type = string
}

variable "env" {
  type = string
}

variable "eks_ca_cert" {
  type = list(map(string))
}

variable "eks_cluster_endpoint" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}