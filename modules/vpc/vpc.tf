# vpc

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr

  region = var.vpc_region

  tags = {
    Name = "main"
  }
}

# create both public subnets using for loop
variable "public_subnets" {
  type    = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "eu-west-2${each.key}" # create public subnets in eu-west-2a and eu-west-2b
  map_public_ip_on_launch = true # give both subnets public IP

  tags = {
    Name = "public-AZ-${each.key}"
  }
}

# internet gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# create route table for public subnets to route all traffic to the internet to the IGW
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
resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id
}


# create ALB
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = "main"
  }
}