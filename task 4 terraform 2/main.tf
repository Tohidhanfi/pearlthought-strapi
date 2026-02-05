terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- SSH Key Generation ---
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}
# --------------------------

module "network" {
  source   = "./modules/networking"
  app_port = 1337
}

module "server" {
  source = "./modules/compute"

  instance_type       = var.instance_type
  key_name            = aws_key_pair.kp.key_name
  security_group_id   = module.network.app_sg_id
  subnet_id           = module.network.public_subnet_ids[0]
  
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    environment = var.environment
  })
}

variable "instance_type" { default = "c7i-flex.large" }

variable "key_name" { default = "strapi-key" }

variable "region" { default = "ap-south-1" }

variable "environment" { default = "development" }

output "app_url" {
  value = "http://${module.server.public_ip}:1337"
}

output "ssh_command" {
  value = "ssh -i ${local_file.ssh_key.filename} ubuntu@${module.server.public_ip}"
}

output "vpc_id" {
  value = module.network.vpc_id
}
