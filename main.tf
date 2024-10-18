provider "aws" {
    region = "eu-east-1"
}

resource "aws-instance" "example" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = "t2.micro"

    tags={
        Name="TerraformExampleInstance"
    }
}