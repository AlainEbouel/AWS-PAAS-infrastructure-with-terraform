resource "aws_vpc" "microsoft-ad" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.module-name}-${var.env}"
  }
}

resource "aws_subnet" "private-microsoft-ad" {
  for_each          = var.private-subnets
  vpc_id            = aws_vpc.microsoft-ad.id
  cidr_block        = var.private-subnets[each.key].cidr_block
  availability_zone = var.private-subnets[each.key].AZ

  tags = {
    # "kubernetes.io/role/internal-elb" = "1"
    "name" = "${var.module-name}-${var.env}-${var.private-subnets[each.key].name}"
  }
}
