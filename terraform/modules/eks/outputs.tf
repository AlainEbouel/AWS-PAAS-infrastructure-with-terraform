output "private-subnets" {
  value = toset([aws_subnet.private-eks-cluster]).*
}

output "eks-cluster-endpoint" {
  value = aws_eks_cluster.dev-cluster.endpoint
}

output "eks-cluster-security_groups" {
  value = aws_eks_cluster.dev-cluster.vpc_config[0].cluster_security_group_id
}

output "eks-cluster-vpc" {
  value = aws_vpc.eks-cluster.id
}

output "eks-cluster-node-group-role" {
  value = aws_iam_role.node-group.name
}

output "eks_ca_cert" {
  value = aws_eks_cluster.dev-cluster.certificate_authority
}
output "eks_cluster_name" {
  value = aws_eks_cluster.dev-cluster.name
}

output "eks-node-group-name" {
  value = aws_eks_node_group.eks_cluster.node_group_name
}
