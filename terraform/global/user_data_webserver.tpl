#!/bin/bash

export GOPATH=/go
export APP_DIR=/challenge-fc/demo-app
export ELB_DNS=${elb_dns}
export PRIV_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo $PRIV_IP

sudo yum install -y nginx docker git
sudo usermod -a -G docker ec2-user
sudo service docker restart
sudo git clone https://github.com/clamorisse/challenge-fc.git

# Config nginx server

#req -> elb:80 -> ec2:80 -> nginx -> /demo-app -> 8080

#sudo service nginx restart

# Simple home page

cat > /usr/share/nginx/html/index.html << EOF
<html>
  <head>
    <title>Frontend NGINX</title>
  </head>
  <body>
    <center><h1>Welcome to the Demo application</h1></center><br>
    
    <center><h3>This application uses NGINX to redirect all requests to HTTPS</h3></center><br>
    <center><h3>NGINX runs in a container, check the <a href="https://hub.docker.com/r/clamorisse/nginx-ssl-container/">image</a>.</h3></center><br>
    <center><h3>The application itself runs in a container</h3></center><br>
    <center><h3>that communicates to a DB MySQL, also runing in a container.</h3></center><br>
    <center><h3><a href="http://redirect.cotero.org/demo-app">START</a></h3></center><br>
    
    <center>NGINX Status: running</center>
    <center>by: Berenice V. Cotero</center>
  </body>
</html>
EOF

docker run --net=host -d -p 80:80 -p 443:443 -v /usr/share/nginx/html/index.html:/usr/share/nginx/html/index.html clamorisse/nginx-ssl-container
docker ps -a

mkdir go || true

# Get required go packages 
docker run --rm -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -w /usr/src/myapp golang:1.6 go get golang.org/x/crypto/bcrypt

docker run --rm -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -w /usr/src/myapp \
  golang:1.6 go get -v -u github.com/mattes/migrate

# Checking connection to database
nc -z -w1 ${db_host} 3306
while [ $? -ne 0 ]
do
  echo "Waiting for database..."
  nc -z -w1 ${db_host} 3306
done
echo "OMG DB is finally up!"

# Run db migrations
export MYSQL_PASSWORD=pass
export MYSQL_USER=usuario
export MYSQL_DATABASE=login-app
export MYSQL_HOST=${db_host}

ls -la $APP_DIR

docker run --name=DBmigration -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -w /usr/src/myapp  \
  golang:1.6 migrate \
  -url mysql://$MYSQL_USER:$MYSQL_PASSWORD@tcp\($MYSQL_HOST:3306\)/$MYSQL_DATABASE \
  -path migrations up

docker logs DBmigration

echo "migrations are up!"
echo
echo "starting app"

# Run the app
docker run --net=host --rm -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -e MYSQL_PASSWORD=pass \
  -e MYSQL_USER=usuario \
  -e MYSQL_DATABASE=login-app \
  -e MYSQL_HOST=${db_host} \
  -p 8080:8080 \
  -w /usr/src/myapp \
  golang:1.6 go run signup.go -v

echo "consumatum est..."
