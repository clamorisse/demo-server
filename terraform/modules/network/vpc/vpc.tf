// -------------------------------------------------
//          MODULE THAT CREATES A VPC IN AWS
// ------------------------------------------------

variable "name"              { default = "vpc"}
variable "cidr"              { }

resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${var.name}" 
  }
}

output "vpc_id"   { value = "${aws_vpc.vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.vpc.cidr_block}" }
