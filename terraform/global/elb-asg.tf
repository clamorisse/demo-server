
resource "aws_elb" "elb" {
  name = "app-elb"
  subnets = ["${module.public_subnet.subnet_ids}"]
  security_groups = ["${aws_security_group.elb.id}"]

  listener {
    instance_port = "443"
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }
  
  listener {
    instance_port = "80"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }

  cross_zone_load_balancing = true
}

resource "aws_launch_configuration" "launch_config" {
  name = "web-lc"
  image_id = "${var.amazon-linux-ami}"
  instance_type = "t2.large"
  key_name = "${var.key-name}"
  security_groups = ["${aws_security_group.web_server_sg.id}"]
  user_data = "${template_file.webserver_userdata.rendered}"
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "main_asg" {
  # We want this to explicitly depend on the launch config above
  depends_on = ["aws_launch_configuration.launch_config"]

  name = "web-asg"

  # The chosen availability zones *must* match the AZs the VPC subnets are tied to.
  vpc_zone_identifier = ["${module.public_subnet.subnet_ids}"]

  # Uses the ID from the launch config created above
  launch_configuration = "${aws_launch_configuration.launch_config.id}"

  max_size = "2"
  min_size = "2"
  desired_capacity = "2"

  health_check_grace_period = "300"
  health_check_type = "ELB"

  load_balancers = ["${aws_elb.elb.name}"]
}

output "elb" { value = "${aws_elb.elb.dns_name}" }
