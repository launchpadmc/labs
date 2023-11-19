resource "aws_vpc" "custom" {

  # IP Range for the VPC
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom"
  }
}

# data "aws_availability_zones" "available" {
#   state = "available"
# }

# output "az_c" {
#   value = data.aws_availability_zones.available.names[2]
# }

resource "aws_subnet" "public" {
  count = length(var.subnet_cidrs_public)
  depends_on = [
    aws_vpc.custom
  ]
  vpc_id = aws_vpc.custom.id

  # IP Range of this subnet
  cidr_block = element(var.subnet_cidrs_public, count.index)

  # Data Center of this subnet.
  availability_zone = element(var.az_public, count.index)

  # Enabling automatic public IP assignment on instance launch
  map_public_ip_on_launch = true

  tags = {
    Name = "${element(var.az_public, count.index)} - Public Subnet"
  }
}

resource "aws_subnet" "private" {
  depends_on = [
    aws_vpc.custom,
    aws_subnet.public
  ]

  vpc_id = aws_vpc.custom.id

  # IP Range of this subnet
  cidr_block = var.subnet_cidr_private

  # Data Center of this subnet.
  availability_zone       = var.az_private
  map_public_ip_on_launch = false
  tags = {
    Name = "${(var.az_private)} - Private Subnet"
  }
}

resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.custom,
    aws_internet_gateway.Internet_Gateway
  ]

  # VPC ID
  vpc_id = aws_vpc.custom.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.public,
    aws_subnet.private,
    aws_route_table.Public-Subnet-RT
  ]

  # Public Subnet ID
  count     = length(var.subnet_cidrs_public)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  #  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP,
    aws_internet_gateway.Internet_Gateway
  ]

  allocation_id = aws_eip.Nat-Gateway-EIP.id

  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "Nat-Gateway"
  }
}

resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.custom,
    aws_subnet.private,
    aws_subnet.public
  ]

  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "Internet-Gateway"
  }
}

resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.RT-IG-Association,
    aws_internet_gateway.Internet_Gateway
  ]
  vpc              = true
  public_ipv4_pool = "amazon"
  tags = {
    Name = "ElasticIP"
  }
}

