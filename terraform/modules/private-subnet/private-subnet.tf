#--------------------------------------------------------------
#  MODULE THAT CREATES A PRIVATE SUBNET AND 
#  OTHER NECESSARY RESOURCES
#--------------------------------------------------------------

variable "name"           { default = "private_subnet"}
variable "vpc_id"         { }
variable "cidr"           { }
variable "az"             { }
variable "nat_gateway_id" { }

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.cidr}" 
  availability_zone = "${var.az}"

  tags      { Name = "${var.name}.${var.az}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
#  count  = "${var.cidr}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_gateway_id}"
  }

  tags      { Name = "${var.name}.${var.az}" }
  lifecycle { create_before_destroy = true }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"

  lifecycle { create_before_destroy = true }
}

output "subnet_id" { value = "${aws_subnet.private.id}" }
