resource "aws_instance" "test" {
  ami                     = "ami-0cb226682278979e9"
  instance_type           = var.instance_type
}
resource "aws_instance" "web" {
  ami                     = "ami-0cb226682278979e9"
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
