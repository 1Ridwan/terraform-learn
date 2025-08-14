resource "aws_instance" "this" {
  ami                     = "ami-0cb226682278979e9"
  instance_type           = "t2.micro"
}