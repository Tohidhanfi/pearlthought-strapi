variable "instance_type" {}
variable "key_name" {}
variable "security_group_id" {}
variable "subnet_id" {}
variable "user_data" {}

resource "aws_instance" "strapi" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  associate_public_ip_address = true
  
  vpc_security_group_ids = [var.security_group_id]
  user_data              = var.user_data

  tags = {
    Name = "strapi-server-public"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

output "instance_id" { value = aws_instance.strapi.id }
output "public_ip" { value = aws_instance.strapi.public_ip }
output "private_ip" { value = aws_instance.strapi.private_ip }
