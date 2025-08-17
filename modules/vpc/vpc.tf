# vpc

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr

  region = var.vpc_region

  tags = {
    Name = "main"
  }
}

# public subnet 1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/28"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_az1"
  }
}

#public subnet 2

resource "aws_subnet" "public_subnet_az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.16/28"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_az2"
  }
}

# internet gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# create route table for public subnets to route traffic to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "public_route_table"
  }
}

# associate the route tables for both public subnets
resource "aws_route_table_association" "public-az1" {
    subnet_id = aws_subnet.public_subnet_az1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-az2" {
    subnet_id = aws_subnet.public_subnet_az2.id
    route_table_id = aws_route_table.public.id
}