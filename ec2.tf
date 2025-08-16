resource "aws_instance" "test" {
  ami                     = local.instance_ami
  instance_type           = var.instance_type
  tags = {
      Name = "terraform-demo"
      }
  user_data_replace_on_change = false
}


resource "aws_instance" "web" {
  ami                     = local.instance_ami
  instance_type           = var.instance_type

  tags = {
    Name = "terraform-test"
  }
  user_data_replace_on_change = false
}

import {
  to = aws_instance.web
  id = "i-0cea5e9b4bc689cfa"
}
