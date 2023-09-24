resource "aws_vpc" "global-infra" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_route_table" "global-infra" {
  vpc_id = aws_vpc.global-infra.id

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_subnet" "private-global-infra" {
  for_each                = var.private-subnets
  vpc_id     = aws_vpc.global-infra.id
  cidr_block = var.private-subnets[each.key].cidr_block
  availability_zone       = var.private-subnets[each.key].AZ

  tags = {
    Name = var.private-subnets[each.key].name
  }
}

resource "aws_route_table_association" "private-global-infra" {
  for_each                = var.private-subnets
  subnet_id      = aws_subnet.private-global-infra[each.key].id
  route_table_id = aws_route_table.global-infra.id
}

# resource "aws_network_acl" "private-global-infra" {
#   vpc_id = aws_vpc.global-infra.id

#   egress {
#     protocol   = "-1"
#     rule_no    = 200
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   ingress {
#     protocol   = "-1"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   tags = {
#     Name = "main-NACL-${var.env}"
#   }
# }

# resource "aws_network_acl_association" "private-global-infra" {
#   for_each                = var.private-subnets
#   network_acl_id = aws_network_acl.private-global-infra.id
#   subnet_id      = aws_subnet.private-global-infra[each.key].id
# }



