resource "aws_vpc" "eks-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc-${var.env}"
  }
}

resource "aws_internet_gateway" "eks-vpc_igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "main-vpc-igw${var.env}"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-vpc_igw.id
  }

  tags = {
    Name = "main-route-table-${var.env}"
  }
}

resource "aws_subnet" "public-subnet" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public_subnets[each.key].cidr_block
  availability_zone       = var.public_subnets[each.key].AZ
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnets[each.key].name
  }
}

resource "aws_subnet" "private-subnet" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = var.private_subnets[each.key].cidr_block
  availability_zone = var.private_subnets[each.key].AZ

  tags = {
    Name = var.private_subnets[each.key].name
  }
}

resource "aws_route_table_association" "public-subnet-route_table-association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public-subnet[each.key].id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "private-subnet-route_table-association" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.private-subnet[each.key].id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_network_acl" "public-NACL" {
  vpc_id = aws_vpc.eks-vpc.id

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
    Name = "main-NACL-${var.env}"
  }
}

resource "aws_network_acl_association" "public-subnet-NACL-association" {
  for_each       = var.public_subnets
  network_acl_id = aws_network_acl.public-NACL.id
  subnet_id      = aws_subnet.public-subnet[each.key].id
}



