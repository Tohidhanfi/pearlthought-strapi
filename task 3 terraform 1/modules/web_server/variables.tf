variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "private_key_pem" {
  description = "Private key content for connection"
  type        = string
}

variable "app_source_path" {
  description = "Path to the local Strapi application"
  type        = string
}
