# Golang demo app with MySQL database 

This a simple web-service in Go to demo data persistence in MySQL. NGINX is used to redirect all requests to https. The servers are in a autoscaling group and attached to a load balacer.


## Requirements

This application requires:

* Terraform v0.7.5 or newer
* AWS account and aws profile configured with the keys
* An ec2 key-pair created in advance
* A Route53 record to redirect requests to ELB end point set up manually, and change nginx.conf accordingly.

## How it works

Terraform provisions servers and installs required services via user-data. MySQL database runs in a container, as well as Go application.

A NGINX web server is used as a reverse proxy for the application and to redirect all http requests to https, it runs in a container and creates SSL certificates.
To check the image: []

## How to run

The application deployment is fully automated. Run `terraform plan` and then `terraform apply` from terraform folder. 
After completion, terraform will output the ip address for the web server. Open url http://webserver-ip/demo-app in the browser. 

## TODO
* Add load balancing.
* Provision key pair with terraform.
* Enable logging in the app. 
* Get DB parameters via service discovery.

