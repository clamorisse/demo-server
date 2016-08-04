# Golang demo app with MySQL database 

This a simple web-service in Go to demo data persistence in MySQL.


## Requirements

This application application requires:

* Terraform  v0.6.16 or newer
* AWS account and aws profile configured with the keys
* An ec2 key-pair created in advance

## How it works

Terraform provisions servers and installs required services via user-data. MySQL database runs in a container, as well as Go application.

A NGINX web server is used as a reverse proxy for the application.

## How to run

The application deployment is fully automated. Run `terraform plan` and then `terraform apply` from terraform folder. 
After completion, terraform will output the ip address for the web server. Open url http://webserver-ip/demo-app in the browser. 

## TODO
Add load balancing.
Provision key pair with terraform.
Enable logging in the app. 
Get DB parameters via service discovery.

