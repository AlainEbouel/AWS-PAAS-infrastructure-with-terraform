
resource "aws_security_group" "msk_cluster" {
  name        = "mks-cluster"
  description = "Security group to control who can communicate with the mks-cluster"
  vpc_id      = aws_vpc.global-infra.id

  ingress {
    description      = "Allow all traffic from eks-cluster security group"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [var.eks-cluster-security_group]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "global-infra" {    
  cluster_name = "${var.module-name}-${var.env}"

  broker_node_group_info {
    client_subnets = [for k, v in aws_subnet.private-global-infra : v.id]
    instance_type = "kafka.t3.small"
    security_groups = [aws_security_group.msk_cluster.id]
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
  }

  kafka_version = "2.8.1"
  number_of_broker_nodes = 2

  depends_on = [ aws_vpc_peering_connection.eks-to-global ]

}


/******************************************************************************************************************/
/* This section defines the role that a specifique service has to assume to communicate with the msk cluster
/*****************************************************************************************************************/

resource "aws_iam_policy" "msk_cluster-policy" {
  name        = "msk_cluster-policy"
  description = "To communicate with the msk cluster"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Resource = ["arn:aws:kafka:${var.region}:${var.aws-account}:cluster/${aws_msk_cluster.global-infra.cluster_name}/*"]
        Action = [ 
          "kafka-cluster:Connect",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:DescribeCluster"
        ]
        Effect = "Allow"
      },
      {
        Resource = ["arn:aws:kafka:${var.region}:${var.aws-account}:topic/${aws_msk_cluster.global-infra.cluster_name}/*"]
        Action = [ 
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ]
        Effect = "Allow"
      },
      {
        Resource = ["arn:aws:kafka:${var.region}:${var.aws-account}:group/${aws_msk_cluster.global-infra.cluster_name}/*"]
        Action = [ 
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eksNodeGroup-to-msk_cluster" {
  policy_arn = aws_iam_policy.msk_cluster-policy.arn
  role       = var.eks-cluster-node-group-role
}

/******************************************************************************************************************/
/* msk client ec2
/*****************************************************************************************************************/
resource "aws_security_group" "msk-client-ec2-sg" {
  name        = "msk-client-ec2-sg"
  description = "Allow traffic with mks cluster"
  vpc_id      = aws_vpc.global-infra.id

  ingress {
    description     = "allow http from alb"
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.msk_cluster.id]
  }

  ingress {
    description = "allow ssh from personal ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk-client-ec2-sg"
  }
}
data "aws_key_pair" "progi-laptop" {
  key_name = "progi-laptop"
}

resource "aws_instance" "msk-client" {
  ami           = "ami-0940df33750ae6e7f"
  
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.msk-client-ec2-sg.id]
  key_name = data.aws_key_pair.progi-laptop.key_name
  subnet_id = aws_subnet.private-global-infra["subnet1"].id

  tags = {
    Name = "msk_client"
  }
}
