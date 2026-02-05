variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

# Generate a new private key
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add the key to AWS
resource "aws_key_pair" "generated" {
  key_name   = var.key_name
  public_key = tls_private_key.generated.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.root}/${var.key_name}.pem"
  file_permission = "0400"
}
