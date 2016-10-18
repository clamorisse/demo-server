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

variable "app-name"         { }
variable "env"              { }

variable "ec2"              { }
variable "number"           { }
variable "ec2-type"         { }
variable "amazon-linux-ami" { default = "ami-6869aa05" }
variable "key-name"         { default = "server-key" }

variable "vpc-cidr"         { }
variable "igw-name"         { }

variable "az-pub"           { }
variable "cidr-pub"         { }
variable "name-pub-subnet"  { }

variable "az-priv"          { }
variable "cidr-priv"        { }
variable "name-priv-subnet" { }

/*
variable "vpc_id"           { }
variable "public_subnet_id" { }
variable "private_az"       { }
variable "public_az"        { }
variable "private_cidr"     { }
*/

# ------------------------------------------------

# CREATES VPC, PUBLIC AND PRIVATE SUBNETS 

module "vpc" {
  source = "../modules/network/vpc"

  name   = "${var.app-name}-vpc"
  cidr   = "${var.vpc-cidr}" 
}

module "public_subnet" {
  source = "../modules/network/subnet/public-subnet" 

  vpc_id            = "${module.vpc.vpc_id}"
  cidr_block        = "${var.cidr-pub}"
  availability_zone = "${var.az-pub}"
  name              = "${var.app-name}-${var.name-pub-subnet}"
}

module "nat" {
  source = "../modules/network/nat"

  name              = "nat"
  az                = "${var.az-pub}"
  public_subnet_id  = "${module.public_subnet.subnet_ids}"
}

module "private_subnet" {
  source = "../modules/network/subnet/private-subnet"

  name   = "${var.app-name}-private_subnet"
  vpc_id = "${module.vpc.vpc_id}"
  cidr  = "${var.cidr-priv}"
  az     = "${var.az-priv}"

  nat_gateway_id = "${module.nat.nat_gateway_id}"
}

resource "aws_security_group" "elb" {
  name        = "elb_server_sg"
  description = "Allows hhtp, https traffic from Internet"
  vpc_id      = "${module.vpc.vpc_id}"

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

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allows hhtp, https and ssh traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
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
  vpc_id      = "${module.vpc.vpc_id}" 
  
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
  instance_type               = "t2.large"
  associate_public_ip_address = "false" 
  key_name                    = "${var.key-name}"
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
    elb_dns = "${aws_elb.elb.dns_name}"
  }
}

output "db_server_private_ip" { value = "${aws_instance.db_server.private_ip}" }
