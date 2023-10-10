resource "aws_iam_role" "node-group" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-group.name 
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-group.name
}

resource "aws_eks_node_group" "eks_cluster" {
  cluster_name    = aws_eks_cluster.dev-cluster.name
  node_group_name = "${var.module-name}-${var.env}"
  node_role_arn   = aws_iam_role.node-group.arn
  subnet_ids      = [for k, v in aws_subnet.private-eks-cluster : v.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  capacity_type = "ON_DEMAND"
  disk_size = "20"

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_eks_cluster.dev-cluster
  ]
}

data "aws_instances" "node-group-instances" {
  instance_tags = {
    "eks:nodegroup-name" = aws_eks_node_group.eks_cluster.node_group_name
  }
  instance_state_names = ["running"]
}

data "aws_instance" "node-group-instance" {
  instance_id = data.aws_instances.node-group-instances.ids[0]
}

data "aws_ebs_snapshot" "node-group-ebs-snapshot" {
  most_recent = true

  filter {
    name   = "volume-size"
    values = ["5"]
  }
}

resource "aws_ebs_volume" "node-group-ebs" {
  availability_zone = data.aws_instance.node-group-instance.availability_zone
  size              = 5
  final_snapshot = true
  type = "gp2"

  tags = {
    name = "node-group-ebs"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.node-group-ebs.id
  instance_id = data.aws_instance.node-group-instance.id
  # depends_on = [ aws_eks_node_group.eks_cluster ]
}

