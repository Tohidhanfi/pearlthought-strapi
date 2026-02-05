# pearlthought-strapi

## Task 1 ? Strapi setup

This repository contains a Strapi CMS project inside the `strapi-app` folder. The goal of Task 1 was to get this project running locally and walk through the basic structure and usage.

### What was done in Task 1

- Generated a Strapi project in the `strapi-app` directory.
- Confirmed the application runs locally in development mode.
- Recorded a Loom video explaining what Strapi is, the folder structure, and how to run it locally.

### How to run the project locally

1. Install **Node.js v20+**.
2. From the repo root, go into the Strapi app:
   ```bash
   cd strapi-app
   npm install
   npm run develop
   ```
3. Open `http://localhost:1337/admin` in your browser and create the first admin user.

### Loom walkthrough

- Loom link for Task 1 demo: <ADD_LOOM_LINK_HERE>

## Task 2 – AWS & Terraform

In this task, the focus shifted to cloud infrastructure.
- **Objective**: Learn AWS core concepts and provision resources using Infrastructure as Code (Terraform).
- **Actions**:
  - Manually launched an EC2 instance via the AWS Console to understand the basics.
  - Wrote a Terraform script to automate the provisioning of the same infrastructure.
- **Documentation**: A detailed log of the process is available in [Task 2 Documentation](./task%202/aws_terraform_journey.md).

## Task 3 – Modular Terraform & Automating Strapi

For this third task, we took everything a step further by fully automating the deployment process using a robust, modular approach.

### What we built
Instead of a single script, I organized the infrastructure into reusable **modules** (`ssh_key`, `web_server`) to keep things clean and professional.

### Key Highlights
- **Automated Everything**: The Terraform script now generates its own SSH key pair on the fly—no manual key creation needed.
- **"Strapi Tohid" Server**: Provisioned an Ubuntu EC2 instance (creatively named **strapi tohid**) that automatically installs Node.js, PM2, and a fresh Strapi app.
- **Standard Practices**: We switched to using the **Default VPC** for simplicity and reliability.
- **Zero-Touch Deployment**: You just run `terraform apply`, and it spits out the server IP and the running Strapi URL.

The code for this task is located in the `task 3 terraform 1` folder, demonstrating how infrastructure-as-code can make life easier.

## Task 4 – Custom VPC & Dockerized Deployment

Final production-ready architecture implemented in `task 4 terraform 2`:

- **Infrastructure**: Custom VPC with Public/Private subnets and NAT Gateway.
- **Compute**: Public EC2 instance (due to account LB limits) running Docker.
- **Application**:
  - **Strapi**: Runs in a container using custom images (`tohidazure/strapi-app:prod/dev`).
  - **Database**: Dedicated **PostgreSQL** container (TCP connected), solving SQLite permissions issues.
  - **Dynamic Config**: `user_data` script auto-selects image tags based on Terraform workspace env (`dev`/`prod`).
- **Automation**: `terraform apply` fully provisions network, server, and launches the app stack.