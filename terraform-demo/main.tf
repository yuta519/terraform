provider "aws" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  region     = "ap-northeast-1"
}
variable "ACCESS_KEY" {
      type = string
}
variable "SECRET_KEY" {
      type = string
}
data aws_ssm_parameter amzn2_ami {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
resource "aws_instance" "myinstance" {
  ami = data.aws_ssm_parameter.amzn2_ami.value
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "Hello World from TF" > /var/www/html/index.html
  EOF
  tags = {
        Name = "instance_from_terraforms"
    }
}
resource "aws_security_group" "tf-sg" {
    name = "sg_for_tf"
    description = "security group for Terraform"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
