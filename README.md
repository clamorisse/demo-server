### Challenge-fc

This is a repository that creates the infrastructure in AWS necessary to run a simple golang application.
The creation of infrastructure and deployment of application, are automated using a terraform plan.

## How to use?

To deploy in AWS, you need to have created a default profile to run Terraform tf files.
In terraform directory

```
terraform plan
terraform apply
```

## The Front end

Consists of a EC2 instance listening in ports HTTP, HTTPS and SSH. At creation it is boot with file ```user_data_wev_server.tpl``` and has a dependency on the creation of the back end instance. 
