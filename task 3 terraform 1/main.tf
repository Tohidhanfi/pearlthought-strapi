# Fetch the latest Ubuntu 22.04 AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "ssh_key" {
  source   = "./modules/ssh_key"
  key_name = var.key_name
}

module "strapi_server" {
  source          = "./modules/web_server"
  ami_id          = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = module.ssh_key.key_name
  private_key_pem = module.ssh_key.private_key_pem
  app_source_path = var.app_path
}

output "strapi_app_url" {
  value = module.strapi_server.strapi_url
}

output "ssh_command" {
  value = "ssh -i ${var.key_name}.pem ubuntu@${module.strapi_server.public_ip}"
}
