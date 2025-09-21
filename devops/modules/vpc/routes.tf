# --- Public ---
# Публічна таблиця маршрутів (одна на всі публічні)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-rt-public"
  }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
# --- End Public ---

# --- Private ---
# Для NAT робимо по NAT на кожен AZ якщо create_nat_per_az = true, інакше - 1 NAT (для економії)
locals {
  public_keys    = keys(aws_subnet.public)
  nat_keys_list  = var.create_nat_per_az ? local.public_keys : [local.public_keys[0]]
  nat_single_key = local.nat_keys_list[0]
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_keys_list)
  domain   = "vpc"

  tags = { Name = "${var.vpc_name}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_eip.nat
  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.vpc_name}-nat-${each.key}"
  }
}

# Приватні таблиці маршрутів (по одній на AZ для відповідного NAT)
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-rtb-private-${each.key}"
  }
}

resource "aws_route" "private_nat" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[
    var.create_nat_per_az ? each.key : local.nat_single_key
  ].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
# --- End Private ---
