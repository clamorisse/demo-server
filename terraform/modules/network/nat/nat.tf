#--------------------------------------------------------------
#       MODULE THAT CREATES NAT GATEWAY
#--------------------------------------------------------------

variable "name"             { default = "nat" }
variable "az"               { }
variable "public_subnet_id" { type="list"}

resource "aws_eip" "nat" {
  vpc   = true
  count = "${length(split(",", var.az))}"

  lifecycle { create_before_destroy = true }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${var.public_subnet_id[count.index]}"
  count         = "${length(split(",", var.az))}"

  lifecycle { create_before_destroy = true }
}

output "nat_gateway_id" { value = "${join(",", aws_nat_gateway.nat.*.id)}" }
