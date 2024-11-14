provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "example" {
  key_name   = "my-key"
  public_key = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUrXIwLVheKQgGcMY8ElkA1lP2I9acPQ/PouOXLReb1sZtACy4JJSvAhkAI/zq+Ibz+JSUIBPfpQ7sb6gMbIOY3vfEiPyWBMvqmkvUoz+hJt8UwH62MVByhFz+47VERjcaVNC4Sicr4pyAmdcy0YrHX6/B3rQAjRhckVoxZP6J+7IajTHGZFGvkUeD17AtItgHV6/92OHzZObBC+gpCddzT+BV6VO4Z+Vvb2E1j780YsgKH5eLf3HNNT5Q9QIH4dDH916FoUPcAfRv6oOlOWWc6k8G8i94aQwiYKXW1seCRVoAD5k08qV6MSP8An3weAJmPT74UXouSqiVMV2/JVdn+cCV94+UukOIYpljy223Uz+0Jb7fG46suZoyetzaVVDT028ObF/UFXOqHnLuDXYohrg/Ub0Go93L9y0SGgOe51vDu0ieD0Ztjy/iyzDgulYWEoUUmJgweZJZLz77uYzGavDgT9nCqP30NMAsvOmr3h+jYDHelb91Pd3mxLh7lKXmlm3iNacZYgCqalx2Pdy4kp7TC2Tft7iSAioOmS8D1DBjoJfO/Ih91LQvUT1/O/FEtK9Lug3DRxDB94OyHNdmjYlxmjRtTI+UJMDdbDMf+78XD1RZcTl3qOG2dfir7YDqi9GPqvG4edCvF2Cp5DXs2RLrOLrMYeIyvwrXEsEGbw== rkresearchwork11@gmail.com
EOF
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

# Update EC2 Instance to Launch in the New VPC
resource "aws_instance" "example" {
  ami                         = "ami-0c94855ba95c71c99"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id  # Launch in the public subnet
  associate_public_ip_address = true  # Ensure it has a public IP
  key_name                    = aws_key_pair.example.key_name
  
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y python3 python3-pip
    pip3 install flask
  EOF

  tags = {
    Name = "TerraformExampleInstance"
  }

provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/python-app",
      "scp -i /home/rohit/.ssh/my-ec2-key.pem -o StrictHostKeyChecking=no -r python-app ec2-user@${self.public_ip}:/home/ec2-user/python-app",
      "ssh -i /home/rohit/.ssh/my-ec2-key.pem ec2-user@${self.public_ip} 'pip3 install -r /home/ec2-user/python-app/requirements.txt'",
      "ssh -i /home/rohit/.ssh/my-ec2-key.pem ec2-user@${self.public_ip} 'nohup python3 /home/ec2-user/python-app/app.py &'"
    ]
  }
}

output "instance_id" {
    value = aws_instance.example.id
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
