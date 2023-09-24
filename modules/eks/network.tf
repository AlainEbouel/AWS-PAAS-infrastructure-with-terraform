resource "aws_vpc" "global-infra" {
  cidr_block = var.vpc-cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_eip" "eks_cluster" {
  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_nat_gateway" "eks_cluster" {
  allocation_id = aws_eip.eks_cluster.id
  subnet_id     = aws_subnet.public-global-infra["subnet1"].id

  tags = {
    Name = "${var.module-name}-${var.env}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.global-infra]
}

resource "aws_route_table" "private-global-infra" {
  vpc_id = aws_vpc.global-infra.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks_cluster.id
  }
  tags = {
    Name = "private-${var.module-name}-${var.env}"
  }
}

resource "aws_subnet" "private-global-infra" {
  for_each                = var.private-subnets
  vpc_id     = aws_vpc.global-infra.id
  cidr_block = var.private-subnets[each.key].cidr_block
  availability_zone       = var.private-subnets[each.key].AZ

  tags = {
    Name = "${var.module-name}-${var.private-subnets[each.key].name}"
  }
}

resource "aws_route_table_association" "private-global-infra" {
  for_each                = var.private-subnets
  subnet_id      = aws_subnet.private-global-infra[each.key].id
  route_table_id = aws_route_table.private-global-infra.id
}

resource "aws_internet_gateway" "global-infra" {
  vpc_id = aws_vpc.global-infra.id

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_route_table" "public-global-infra" {
  vpc_id = aws_vpc.global-infra.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global-infra.id
  }

  tags = {
    Name = "public-${var.module-name}-${var.env}"
  }
}

resource "aws_subnet" "public-global-infra" {
  for_each                = var.public-subnets
  vpc_id                  = aws_vpc.global-infra.id
  cidr_block              = var.public-subnets[each.key].cidr_block
  availability_zone       = var.public-subnets[each.key].AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.module-name}-${var.public-subnets[each.key].name}"
  }
}

resource "aws_route_table_association" "public-global-infra" {
  for_each                = var.public-subnets
  subnet_id      = aws_subnet.public-global-infra[each.key].id
  route_table_id = aws_route_table.public-global-infra.id
}

resource "aws_network_acl" "public-global-infra" {
  vpc_id = aws_vpc.global-infra.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_network_acl_association" "public-global-infra" {
  for_each                = var.public-subnets
  network_acl_id = aws_network_acl.public-global-infra.id
  subnet_id      = aws_subnet.public-global-infra[each.key].id
}



