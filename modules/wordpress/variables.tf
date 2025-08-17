variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "instance_ami" {
  type = string
   default = "ami-0cb226682278979e9"
}

variable "az1" {
  type = string
  default = "eu-west-2a"
}

variable "az2" {
  type = string
  default = "eu-west-2b"
}

output "instance_id" { 
    description = "The id of the EC2 instance"
    value = aws_instance.test.id
}

output "public_ip_alb" { 
    description = "The public IP of the ALB"
    value = alb.test.IP
}


