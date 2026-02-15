# Static /24 subnets derived from VPC CIDR (e.g. 10.0.0.0/16 -> public 10.0.1.0/24, 10.0.2.0/24; private 10.0.11.0/24, 10.0.12.0/24)
locals {
  # 8 new bits: /16 -> /24. Public use netnum 1,2,3...; private use 11,12,13... to avoid overlap.
  public_subnet_cidrs = [for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i + 1)]
  private_subnet_cidrs = [for i in range(length(var.availability_zones)) : cidrsubnet(var.vpc_cidr, 8, i + 11)]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

# Public subnets (/24 each)
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${var.availability_zones[count.index]}"
    },
    var.eks_cluster_name != "" ? {
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {}
  )
}

# Private subnets (/24 each)
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.name}-private-${var.availability_zones[count.index]}"
    },
    var.eks_cluster_name != "" ? {
      "kubernetes.io/role/internal-elb"             = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {}
  )
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

# NAT gateway in first public subnet
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# Private route table
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = {
    Name = "${var.name}-private-rt"
  }
}

# Public route table associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table associations
resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
