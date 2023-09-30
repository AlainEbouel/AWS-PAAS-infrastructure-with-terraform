output "private-subnets" {
  value = toset([aws_subnet.private-global-infra]).*
}

output "eks-cluster-endpoint" {
  value = aws_eks_cluster.dev-cluster.endpoint
}