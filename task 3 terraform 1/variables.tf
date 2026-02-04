variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "What to name the generated SSH key"
  type        = string
  default     = "strapi-key-task3"
}

variable "instance_type" {
  description = "EC2 Instance Type (c7i-flex.large used for robust Strapi v5 builds)"
  type        = string
  default     = "c7i-flex.large"
}

variable "app_path" {
  description = "Where to find the local Strapi code to upload"
  type        = string
  default     = "../strapi-app"
}
