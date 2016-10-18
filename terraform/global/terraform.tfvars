# --------------------------------------------------------
#                    GLOBAL VARIABLES
# --------------------------------------------------------

aws-region           = "us-east-1"
profile-name         = "default"
object-name          = "terraform.tfstate"
app-name             = "demo" 
env                  = "global"

# names and type of instances that will be create

ec2                 = "web-server"
number              = "2"
ec2-type            = "t2-micro"
amazon-linux-ami    = "ami-6869aa05"
#public_ip           = "true"
key-name            = "server-key"

// vpc id, availability zone and cidr block for the Subnet 

vpc-cidr            = "10.0.0.0/16"
igw-name            = "main"

az-pub              = "us-east-1a,us-east-1b"
cidr-pub            = "10.0.0.0/24,10.0.10.0/24"
name-pub-subnet     = "pubsubnet"

az-priv             = "us-east-1c"
cidr-priv           = "10.0.20.0/24"
name-priv-subnet    = "privsubnet"


