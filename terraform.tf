variable "tf_region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.tf_region}"
}

variable "amazon-linux-ami" { 
  default = "ami-6869aa05"
}

resource "aws_instance" "web_server" {
  ami = "${var.amazon-linux-ami}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "server-key"
  tags {
    Name = "nginx"
  }
}

output "public_ip" { value = "aws_instance.web_server.public_ip" }
