# Using the default VPC for this project
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "strapi" {
  name        = "strapi-sg"
  description = "Security group for Strapi server"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Strapi default port
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "strapi" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.strapi.id]

  tags = {
    Name = "strapi tohid"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key_pem
    host        = self.public_ip
    timeout     = "4m"
    agent       = false 
  }

  # Install Node.js, create a fresh Strapi app, and run it
  provisioner "remote-exec" {
    inline = [
      # Wait for cloud-init
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      
      # DISABLE INTERACTIVE PROMPTS FOR SERVICE RESTARTS (Fix for 'Which services to restart' hang)
      # We tell needrestart to automatically restart services without asking
      "echo '$nrconf{restart} = \"a\";' | sudo tee /etc/needrestart/conf.d/50autorestart.conf || true",
      "export DEBIAN_FRONTEND=noninteractive",
      "export NEEDRESTART_MODE=a", 
      "sudo fallocate -l 2G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab",

      "export DEBIAN_FRONTEND=noninteractive",
      "export CI=true", 
      "sudo apt-get update",
      
      # 1. Install Node.js (v20 required for Strapi v5)
      "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -",
      "sudo apt-get install -y nodejs build-essential",

      # 2. Install PM2
      "sudo npm install -g pm2",

      # 3. Create a fresh Strapi app using the official CLI
      "cd /home/ubuntu",
      "mkdir -p .strapi-updater",
      # Using 'yes n' and flags to suppress all interaction
      "yes n | npx -y create-strapi-app@latest my-strapi-project --quickstart --no-run --skip-cloud --no-example --ts --no-git-init",

      # 4. Configure Strapi to listen on all interfaces
      "cd my-strapi-project",
      "echo 'HOST=0.0.0.0' >> .env",
      "echo 'PORT=1337' >> .env",

      # 5. Build and Start with PM2
      # We use 'pm2 start npm --name strapi -- start' to find the binary correctly
      "export NODE_OPTIONS='--max-old-space-size=4096'", # Increase memory limit for build
      "npm run build", 
      "pm2 start npm --name strapi -- start",
      "pm2 save",
      
      # 6. Configure PM2 for startup persistence
      "sudo pm2 startup systemd -u ubuntu --hp /home/ubuntu",
      "pm2 save"
    ]
  }
}
