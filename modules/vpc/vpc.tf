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
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = "main"
  }
}

# create security group for ALB - allow all incoming HTTP traffic, allow all outgoing traffic

resource "aws_security_group" "alb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {
  security_group_id = aws_security_group.alb_sg.id
 
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# create security group for instances - allow incoming HTTP traffic from ALB, allow all outgoing traffic to the internet

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow HTTP inbound traffic from alb-sg and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "instance_http_from_alb" {
  security_group_id            = aws_security_group.instance_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "instance_all_out" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# next steps:

# create instances
resource "aws_instance" "public" {
  for_each                   = aws_subnet.public  # map of subnets
  ami                        = var.instance_ami
  instance_type              = var.instance_type
  subnet_id                  = each.value.id
  user_data_replace_on_change = false

  tags = {
    Name = "public-${each.key}"  # public-az1, public-az2
  }
}

# create target group (the two instances)

resource "aws_lb_target_group" "main" {
  name = "alb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  for_each         = aws_instance.public
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = each.value.id
  port             = 80
}

# create listener on port 80
# the listener listens on port 80 on the ALB and then forwards this to the two instances in AZ1 and AZ2 depending on weighting

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}                                                                                                                                               

# create user data to setup web page