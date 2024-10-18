# Terraform AWS EC2 Setup
This project contains a basic Terraform configuration for provisioning an AWS EC2 instance. 
The purpose of this setup is to automate the creation of an EC2 instance using Infrastructure as Code (IaC) 
principles, managed by Terraform. The EC2 instance uses the Amazon Linux 2 AMI and is a t2.micro instance type.


## Pre-requisites
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.9.8 or later)
- AWS CLI installed and configured with appropriate access credentials (You’ll need an AWS Access Key ID and Secret Access Key)
- Git installed

## Usage

1. Clone the repository to your local machine:
   ```bash
   git clone git@github.com:RohitManna11/terraform-aws-setup.git
   ```

2. Navigate to the project directory:
   ```bash
   cd terraform-aws-setup
   ```

3. Initialize Terraform to download the necessary provider plugins:
   ```bash
   terraform init
   ```

4. Run `terraform plan` to preview the changes Terraform will make:
   ```bash
   terraform plan
   ```

5. Apply the configuration to provision the EC2 instance:
   ```bash
   terraform apply
   ```

6. Confirm the creation of the resources by typing `yes` when prompted.

7. To delete the resources when you’re done, run:
   ```bash
   terraform destroy
   ```

## Future Enhancements
- Add support for additional AWS services (e.g., S3 buckets, RDS databases).
- Implement automated deployment using a CI/CD pipeline.

## Author
- [Rohit Manna](https://github.com/RohitManna11)


