variable "instance_type" {
  type = string
}

locals {
  instance_ami = "ami-0cb226682278979e9"
}
output "instance_id" { 
    description = "The id of the EC2 instance"
    value = aws_instance.test.id
}

