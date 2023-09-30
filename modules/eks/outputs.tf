output "private-subnets" {
  value = toset([aws_subnet.private-eks-cluster]).*
}

output "eks-cluster-endpoint" {
  value = aws_eks_cluster.dev-cluster.endpoint
}

output "eks-cluster-security_groups" {
  value = aws_eks_cluster.dev-cluster.vpc_config[0].cluster_security_group_id
}