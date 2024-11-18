provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "example" {
  key_name   = "my-key"
  public_key = file("/home/rohit/.ssh/my-key.pub")
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Change this according to your region

  tags = {
    Name = "PublicSubnet"
  }
}

# Create an Internet Gateway (IGW)
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainIGW"
  }
}

# Create a Route Table for the VPC
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a Security Group
resource "aws_security_group" "example_sg" {
  name        = "example-security-group"
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow SSH and HTTP traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from any IP (adjust for stricter security)
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSG"
  }
}

# Update EC2 Instance to Launch in the New VPC
resource "aws_instance" "example" {
  ami                         = "ami-0c94855ba95c71c99"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id  # Launch in the public subnet
  associate_public_ip_address = true  # Ensure it has a public IP
  key_name                    = aws_key_pair.example.key_name
  vpc_security_group_ids      = [aws_security_group.example_sg.id]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y python3 python3-pip git
    
    # Clone the repository containing the Python app
    cd /home/ec2-user
    git clone https://github.com/RohitManna11/terraform-aws-setup.git
    cd terraform-aws-setup/python-app

    # Install Python dependencies
    pip3 install -r requirements.txt

    # Run the Python application
    nohup python3 app.py > app.log 2>&1 &
  EOF

  tags = {
    Name = "TerraformExampleInstance"
  }
}

output "instance_id" {
    value = aws_instance.example.id
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
