
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

}