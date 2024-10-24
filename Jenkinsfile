pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Use Jenkins credentials
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/RohitManna11/terraform-aws-setup.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Do you want to apply these changes?', ok: 'Apply'
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            node {
                cleanWs()  // Ensure this is within a node block
            }
        }
    }
}
