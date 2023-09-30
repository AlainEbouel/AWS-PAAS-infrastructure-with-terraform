output "private-subnets" {
  value = toset([aws_subnet.private-eks-cluster]).*
}