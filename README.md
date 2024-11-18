# Automated Deployment of a Python Flask Application using Terraform and Jenkins

## Overview
This project demonstrates the automated deployment of a Python Flask application on an AWS EC2 instance using Terraform and Jenkins. The deployment includes setting up infrastructure using Terraform and configuring a CI/CD pipeline with Jenkins to automate the deployment process.

---

## Prerequisites

### Tools Required:
1. **Terraform**
2. **Jenkins**
3. **AWS CLI**
4. **Python 3 and Pip**
5. **Git**

### AWS Resources:
- AWS EC2 Instance
- Security Groups
- Key Pair

---

## Infrastructure Setup with Terraform

### Main Components in `main.tf`:
1. **AWS VPC**
2. **Public Subnet**
3. **Internet Gateway**
4. **Route Table and Association**
5. **Security Group with SSH and HTTP Rules**
6. **EC2 Instance**

### Key Highlights:
- The EC2 instance is attached to a security group with SSH (port 22) and HTTP (port 80) access.
- User data installs Python3, Pip, and the Flask application dependencies automatically.

### Terraform Initialization and Deployment:
1. Initialize Terraform:
   ```bash
   terraform init
   ```
2. Apply Terraform Configuration:
   ```bash
   terraform apply -auto-approve
   ```

---

## Jenkins Pipeline Setup

### Key Stages:
1. **Checkout Code**:
   Pull the Flask application code from the GitHub repository.
2. **Terraform Stages**:
   - Initialize
   - Plan
   - Apply
3. **Deployment Stages**:
   - SSH into the instance to verify connectivity.
   - Deploy the Flask application by copying files and installing dependencies.
   - Start the Flask server.

### Sample Jenkinsfile:
```groovy
pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        REGION = 'us-east-1'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/terraform-aws-setup.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Deploy Python App') {
            steps {
                sh '''
                ssh-keyscan -H $EC2_PUBLIC_IP >> ~/.ssh/known_hosts
                ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/.ssh/my-key ec2-user@$EC2_PUBLIC_IP echo "SSH connection successful"
                scp -i /var/lib/jenkins/.ssh/my-key -o StrictHostKeyChecking=no -r python-app ec2-user@$EC2_PUBLIC_IP:/home/ec2-user/
                ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@$EC2_PUBLIC_IP pip3 install -r /home/ec2-user/python-app/requirements.txt
                ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@$EC2_PUBLIC_IP nohup python3 /home/ec2-user/python-app/app.py > /home/ec2-user/app.log 2>&1 &
                ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@$EC2_PUBLIC_IP curl -s http://localhost:80 || echo "Flask server failed to start"
                '''
            }
        }
    }

    post {
        always {
            echo 'Build Completed. Clean-up or other steps can be added.'
        }
    }
}
```

---

## Application Deployment Verification

### Steps:
1. SSH into the instance:
   ```bash
   ssh -i /path-to-your-key ec2-user@<EC2_PUBLIC_IP>
   ```
2. Verify the application is running:
   ```bash
   curl http://<EC2_PUBLIC_IP>
   ```

Expected Output:
```
Hello, World! This is an automated deployment!
```

---

## Folder Structure

```plaintext
terraform-aws-setup/
├── main.tf
├── python-app/
│   ├── app.py
│   ├── requirements.txt
├── Jenkinsfile
└── README.md
```

---

## Notes
- The Flask application runs on port 80 by default.
- For production, consider using a proper web server like Nginx or Apache instead of the Flask development server.
- Monitor resources using AWS CloudWatch for better insights.

