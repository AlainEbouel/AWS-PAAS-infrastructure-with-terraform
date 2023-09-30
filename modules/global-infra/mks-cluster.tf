
# resource "aws_security_group" "msk_cluster" {
#   name        = "mks-cluster"
#   description = "Security group to control who can communicate with the mks-cluster"
#   vpc_id      = aws_vpc.global-infra.id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = [aws_vpc.main.cidr_block]
#     ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_tls"
#   }
# }
# resource "aws_msk_cluster" "global-infra" {    
#   cluster_name = "${var.module-name}-${var.env}"

#   broker_node_group_info {
#     client_subnets = [for k, v in aws_subnet.private-global-infra : v.id]
#     instance_type = "kafka.t3.small"
#     security_groups = []
#   }

#   kafka_version = "2.8.1"
#   number_of_broker_nodes = 2

# }