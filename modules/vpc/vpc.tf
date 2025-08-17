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

  tags = {
    Name = "public_subnet_az1"
  }
}

#public subnet 2


resource "aws_subnet" "public_subnet_az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.16/28"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public_subnet_az2"
  }
}

# internet gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}