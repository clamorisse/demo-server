# ------------------------------------------
#        AWS CONFIGURATION VARIABLES
# ------------------------------------------

variable "tf_region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.tf_region}"
}

# ------------------------------------------------
#    VARIABLES FOR INFRASTRUCTURE CONFIGURATION
# ------------------------------------------------

variable "amazon-linux-ami" { }
variable "vpc_id"           { }
variable "public_subnet_id" { }
variable "private_az"       { }
variable "public_az"        { }
variable "private_cidr"     { default = "172.31.64.0/20" }


# ------------------------------------------------

module "nat" {
  source = "modules/nat"

  name              = "nat"
  az                = "${var.public_az}"
  public_subnet_id  = "${var.public_subnet_id}"
}

module "private_subnet" {
  source = "modules/private-subnet"

  name   = "private_subnet"
  vpc_id = "${var.vpc_id}"
  cidr  = "${var.private_cidr}"
  az     = "${var.private_az}"

  nat_gateway_id = "${module.nat.nat_gateway_id}"
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allows hhtp, https and ssh traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "db_server_sg" {
  name        = "db_server_sg"
  description = "Allows hhtp, https and ssh traffic"
  vpc_id = "${var.vpc_id}" 
  
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = ["${aws_security_group.web_server_sg.id}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "db_server" {
  ami                         = "${var.amazon-linux-ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "false" 
  key_name                    = "server-key"
  subnet_id                   = "${module.private_subnet.subnet_id}"
  user_data                   = "${file("user_data_mysql.txt")}"
  vpc_security_group_ids      = ["${aws_security_group.db_server_sg.id}"]
  
  tags {
    Name = "database_server"
  }
}

resource "template_file" "webserver_userdata" {
  template = "${file("user_data_webserver.tpl")}"
  vars {
    db_host = "${aws_instance.db_server.private_ip}"
  }
}

resource "aws_instance" "web_server" {
  ami                         = "${var.amazon-linux-ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "server-key"
  subnet_id                   = "subnet-e73c64cd" # "public_subnet_id"
  user_data                   = "${template_file.webserver_userdata.rendered}" 
  vpc_security_group_ids      = ["${aws_security_group.web_server_sg.id}"]

  provisioner "file" {
    source = "../demo-app"
    destination = "/home/ec2-user"

    connection {
      user = "ec2-user"
      private_key = "${file("~/.ssh/server-key.pem")}"
      host = "${self.public_ip}"
    }
  }
  tags {
    Name = "nginx"
  }
}

output "web_server_public_ip" { value = "${aws_instance.web_server.public_ip}" }
output "db_server_private_ip" { value = "${aws_instance.db_server.private_ip}" }
