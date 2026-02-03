# My Journey with AWS and Terraform

So, I decided to dive into the world of Cloud Computing and Infrastructure as Code (IaC). To be honest, I've always heard about AWS and Terraform, but actually getting my hands dirty with them was a whole different experience. Here is how it went!

## Getting a Grip on AWS Core Concepts

Before clicking buttons, I had to understand what I was actually dealing with.
- **EC2 (Elastic Compute Cloud):** Basically a virtual computer in the cloud. It's wild that I can spin up a server in seconds.
- **VPC (Virtual Private Cloud):** My own isolated network. Helps keep things secure so not just anyone can access my stuff.
- **IAM (Identity and Access Management):** Security is huge. This controls who can do what. I learned specifically about creating users and giving them specific permissions (like AdministratorAccess) so I'm not using the root account for everything.
- **S3 (Simple Storage Service):** Just a place to dump files (buckets).

## Part 1: Launching an EC2 Instance Manually

I started the "old school" way—using the AWS Management Console.

1.  **Logged in** to the AWS Console.
2.  Navigated to the **EC2 Dashboard** and clicked on that big orange "Launch Instance" button.
3.  **Name & Tags:** I named my instance `My-First-Manual-Instance` just to keep track of it.
4.  **AMI (Amazon Machine Image):** I stuck with the **Amazon Linux 2023 AMI** because it’s Free Tier eligible. No need to spend money while learning!
5.  **Instance Type:** Selected `t2.micro` (again, Free Tier ftw).
6.  **Key Pair:** This was crucial. I created a new key pair (`my-key-pair.pem`), downloaded it, and kept it safe. I learned the hard way that if you lose this, you're locked out.
7.  **Network Settings:** I let it create a default security group but made sure **SSH traffic** was allowed from my IP.
8.  **Launch:** Hit "Launch Instance" and waited a minute.
9.  **Connect:** I grabbed the Public IP, opened my terminal, and used SSH to connect. Seeing that `[ec2-user@ip-...]` prompt felt like a small victory.

## Part 2: Leveling Up with Terraform

Okay, pointing and clicking is fine, but I kept hearing that "pros use code." So, I tried provisioning the same setup using Terraform.

### The Setup
1.  **Installed Terraform** on my local machine.
2.  **AWS CLI:** I had to configure this with my credentials (`aws configure`) so Terraform could talk to my AWS account.

### The Code (`main.tf`)
I created a file named `main.tf` and wrote this script. It felt a bit like magic—defining infrastructure just like I define a function in code.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_terraform_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # I had to look up the AMI ID for my region!
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-Automated-Instance"
  }
}
```

### The Workflow
This is the rhythm I got used to:
1.  `terraform init`: This initialized the directory and downloaded the AWS provider plugin.
2.  `terraform plan`: This was cool—it showed me exactly what it *would* do before actually doing it. A nice safety check.
3.  `terraform apply`: The moment of truth. I typed `yes` to confirm, and watched the logs scroll by.

BAM! A few seconds later, `Apply complete!` showed up. I checked my AWS Console, and there it was—`Terraform-Automated-Instance` running perfectly.

## Cleanup
I realized quickly that I shouldn't leave these running (bills add up!).
- For the manual one, I had to find it and terminate it.
- For the Terraform one? One command: `terraform destroy`. It cleaned up everything automagically.

## Final Thoughts
Manual is great for learning "what" exists, but Terraform is definitely the way to go for the "how." It’s repeatable, cleaner, and honestly, way more satisfying.
