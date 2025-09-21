resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

# Публічні підмережі
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnets :
    idx => { cidr = cidr, az = var.availability_zones[idx] }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${each.key}"
    Tier = "public"
  }
}

# Приватні підмережі
resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnets :
    idx => { cidr = cidr, az = var.availability_zones[idx] }
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.vpc_name}-private-${each.key}"
    Tier = "private"
  }
}

# Internet Gateway для публічних підмереж
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}
