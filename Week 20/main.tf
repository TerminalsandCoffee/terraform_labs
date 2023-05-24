# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  
}

# Create a security group for SSH and Jenkins
resource "aws_security_group" "jenkins" {
  name        = "jenkins-security-group"
  description = "Security group for our Jenkins Server"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = "ami-0bef6cc322bfff646"  # Replace with desired AMI ID
  instance_type          = "t2.micro"
  security_group_ids     = [aws_security_group.jenkins.id]
  associate_public_ip_address = true
  key_name               = "Week20"  # Replace with your key pair name

  user_data = <<-EOF
              #!/bin/bash
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y openjdk-8-jdk jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF
}

# Create an S3 bucket
resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket = "jenkins-artifacts-bucket-created-by-t3rmin4ls"
  acl    = "private"
}
