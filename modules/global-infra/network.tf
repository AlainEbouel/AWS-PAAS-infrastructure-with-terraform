resource "aws_vpc" "global-infra" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_internet_gateway" "global-infra" {
  vpc_id = aws_vpc.global-infra.id

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_route_table" "global-infra" {
  vpc_id = aws_vpc.global-infra.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global-infra .id
  }

  tags = {
    Name = "main-route-table-${var.env}"
  }
}

resource "aws_subnet" "public-global-infra" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.global-infra.id
  cidr_block              = var.public_subnets[each.key].cidr_block
  availability_zone       = var.public_subnets[each.key].AZ
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnets[each.key].name
  }
}

resource "aws_subnet" "private-global-infra" {
  for_each                = var.private_subnets
  vpc_id     = aws_vpc.global-infra.id
  cidr_block = var.private_subnets[each.key].cidr_block
  availability_zone       = var.private_subnets[each.key].AZ

  tags = {
    Name = var.private_subnets[each.key].name
  }
}

resource "aws_route_table_association" "public-global-infra-route_table-association" {
  for_each                = var.public_subnets
  subnet_id      = aws_subnet.public-global-infra[each.key].id
  route_table_id = aws_route_table.global-infra.id
}

resource "aws_route_table_association" "private-global-infra-route_table-association" {
  for_each                = var.private_subnets
  subnet_id      = aws_subnet.private-global-infra[each.key].id
  route_table_id = aws_route_table.global-infra.id
}

resource "aws_network_acl" "public-NACL" {
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
    Name = "main-NACL-${var.env}"
  }
}

resource "aws_network_acl_association" "public-global-infra-NACL-association" {
  for_each                = var.public_subnets
  network_acl_id = aws_network_acl.public-NACL.id
  subnet_id      = aws_subnet.public-global-infra[each.key].id
}



