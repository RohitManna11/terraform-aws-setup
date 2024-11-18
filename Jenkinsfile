pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Ensure this ID matches exactly with the one in Jenkins credentials
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
	REGION = 'us-east-1'
	SSH_KEY = credentials('aws-key-pair')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/RohitManna11/terraform-aws-setup.git'
            }
        }

	stage('Terraform Destroy') {
	    steps {
		sh 'terraform destroy -auto-approve'
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
                sh 'terraform apply -input=false tfplan'
            }
        }
	
	stage('Get EC2 Instance ID and Public IP') {
            steps {
                script {
                // Capture the instance ID outputted by Terraform
                def instanceId = sh(script: "terraform output -raw instance_id", returnStdout: true).trim()
                echo "Retrieved Instance ID: ${instanceId}"  // Debug line

                // Verify that the instance ID is non-empty
                if (instanceId) {
                    env.INSTANCE_ID = instanceId

                    // Use AWS CLI to get the public IP of the created instance
                    def publicIp = sh(script: "aws ec2 describe-instances --instance-ids ${env.INSTANCE_ID} --region ${REGION} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text", returnStdout: true).trim()
                    env.EC2_PUBLIC_IP = publicIp
                } else {
                    error("Instance ID is empty, Terraform output might have failed.")
                }
            }
            echo "EC2 Public IP: ${env.EC2_PUBLIC_IP}"
        }
    }

//	stage('Destroy Terraform'){
//		steps {
//			sh 'terraform destroy -auto-approve'
//}
//}
	stage('Deploy Python App') {
	steps {
		sh '''
		ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@${EC2_PUBLIC_IP} "echo 'SSH connection successful'"
		scp -i /var/lib/jenkins/.ssh/my-key -o StrictHostKeyChecking=no -r python-app ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user/
		ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@${EC2_PUBLIC_IP} "pip3 install -r /home/ec2-user/python-app/requirements.txt"
		ssh -i /var/lib/jenkins/.ssh/my-key ec2-user@${EC2_PUBLIC_IP} "nohup python3 /home/ec2-user/python-app/app.py &"
		'''
	    }
	}

    }

    post {
        always {
            echo "Build Completed. Clean-up or other steps can be added"
        }
    }
}
