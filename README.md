# Challenge-fc

This repository creates AWS infrastructure necessary to run a simple golang application.
The creation of infrastructure and deployment of application, are automated using a terraform plan.

## How to use?

To deploy in AWS, you need to have created a default profile to run Terraform tf files.
In terraform directory

```
terraform plan
terraform apply
```

## Infrastructure

The file ```terraform/terraform.tf``` creates the following resources:

* 1 Public EC2 instance

* 1 Private EC2 instance

* 1 private subnet

* NAT gateway

* security groups for each instance


### Back end

A private EC2 instance sitting on a private subnet and is configured at creation using the file ```user_data_mysql``` that installs docker, configures it and runs a container with MySQL database. 

### Front end

Consists of a EC2 instance listening in ports HTTP, HTTPS and SSH, that runs NGINX web-server used as a reverse proxy for the Demo application. Also, uses docker to create all the dependencies of Go needed to run the Demo application and the application itself is run in a docker container. This instance is configured using the file ```user_data_webserver.tpl``` and it has a dependancy on backend instance.

## To Play with the Demo

Go to:

[index.html](http://54.86.175.141)

[Demo](http://54.86.175.141/demo-app)