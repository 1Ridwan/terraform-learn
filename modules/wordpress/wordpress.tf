#create instance in private instance in AZ1
resource "aws_instance" "private-az1" {
  ami                     = local.instance_ami
  instance_type           = var.instance_type
  availability_zone = var.az1
  region = 
  tags = {
      Name = "private-az1"
      }
  user_data_replace_on_change = false
}

#create instance in private instance in AZ2
resource "aws_instance" "private-az2" {
  ami                     = local.instance_ami
  instance_type           = var.instance_type
  availability_zone = var.az2

  tags = {
      Name = "private-az2"
      }
  user_data_replace_on_change = false
}

