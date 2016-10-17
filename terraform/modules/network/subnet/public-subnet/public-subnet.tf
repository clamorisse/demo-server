// -------------------------------------------------------------
//              MODULE THAT CREATES A PUBLIC SUBNET
// -------------------------------------------------------------

variable "name"                     { default = "public" }
variable "igw_name"                 { default = "igw" } 
variable "vpc_id"                   { }
variable "cidr_block"               { }
variable "availability_zone"        { }

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.igw_name}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  =  "${var.vpc_id}"
  cidr_block              =  "${element(split(",", var.cidr_block), count.index)}"
  availability_zone       =  "${element(split(",", var.availability_zone), count.index)}"
  count                   = "${length(split(",", var.cidr_block))}"

  tags {
    Name = "${var.name}-${element(split(",", var.availability_zone), count.index)}"
  }

  lifecycle { create_before_destroy = true }
  map_public_ip_on_launch = false
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags { Name = "${var.name}-rt" }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.cidr_block))}" 
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

output "subnet_ids" { value = ["${aws_subnet.public.*.id}"] }


