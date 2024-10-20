provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "example"{
    key_name = "my-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"
    key_name = aws_key_pair.example.key_name

    tags={
        Name="TerraformExampleInstance"
    }
}
