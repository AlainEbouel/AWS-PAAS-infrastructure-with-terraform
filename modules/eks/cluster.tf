# resource "aws_iam_role" "eks-cluster" {
#   name = "eks-Cluster"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks-Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks-cluster.name
# }

# # Optionally, enable Security Groups for Pods
# # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
# resource "aws_iam_role_policy_attachment" "eks-vpc-resource-Controller" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks-cluster.name
# }

# data "aws_iam_policy_document" "eks_cluster" {
#   statement {
#     actions = ["*"]
#     resources = [ "*" ]
#     effect = "Allow"
#     principals {
#       type = "AWS"
#       identifiers = ["arn:aws:iam::${var.aws-account}:root"]
#     }    
#   }
#   statement {
#     sid = "Kms encryption"
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = [ "*" ]
#     effect = "Allow"
#     principals {
#       type = "AWS"
#       identifiers = ["arn:aws:iam::${var.aws-account}:role/${aws_iam_role.eks-cluster.name}"]
#     }
#   }
# }

# resource "aws_kms_key" "eks-cluster" {
#   description             = "KMS key for the ${var.env} EKS cluster"
#   deletion_window_in_days = 7
#   tags = { 
#     name = "${var.module-name}-${var.env}"
#   }
#   policy = data.aws_iam_policy_document.eks_cluster.json
# }

# resource "aws_kms_alias" "eks-cluster" {
#   name          = "alias/${var.module-name}-${var.env}"
#   target_key_id = aws_kms_key.eks-cluster.id
# }

# resource "aws_eks_cluster" "dev-cluster" {
#   name     = "dev-cluster"
#   role_arn = aws_iam_role.eks-cluster.arn

#   vpc_config {
#     subnet_ids = [for k, v in aws_subnet.private-eks-cluster : v.id]
#   }
#   encryption_config {
#     provider {
#       key_arn = aws_kms_key.eks-cluster.arn
#     }
#     resources = ["secrets"]
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks-Policy,
#     aws_iam_role_policy_attachment.eks-vpc-resource-Controller,
#   ]
# }

# resource "aws_iam_role" "node-group" {
#   name = "eks-node-group"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.node-group.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.node-group.name 
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.node-group.name
# }

# resource "aws_eks_node_group" "eks_cluster" {
#   cluster_name    = aws_eks_cluster.dev-cluster.name
#   node_group_name = "${var.module-name}-${var.env}"
#   node_role_arn   = aws_iam_role.node-group.arn
#   subnet_ids      = [for k, v in aws_subnet.private-eks-cluster : v.id]

#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   capacity_type = "ON_DEMAND"
#   disk_size = "20"

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
#   ]
# }