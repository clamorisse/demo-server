#!/bin/bash

sudo yum install -y nginx docker
sudo usermod -a -G docker ec2-user
sudo service docker restart
sudo service nginx restart

mkdir go || true
export GOPATH=/home/ec2-user/go
export APP_DIR=/home/ec2-user/demo-app

docker run --rm -v $APP_DIR:/usr/src/myapp -v "$GOPATH":/go -w /usr/src/myapp golang:1.6 go get golang.org/x/crypto/bcrypt

docker run --rm -v $APP_DIR:/usr/src/myapp -v "$GOPATH":/go -w /usr/src/myapp golang:1.6 go get -v -u github.com/mattes/migrate

docker run --rm -v $APP_DIR:/usr/src/myapp -v "$GOPATH":/go -w /usr/src/myapp -e MYSQL_PASSWORD=pass -e MYSQL_USER=usuario -e MYSQL_DATABASE=login-app -e MYSQL_HOST=${db_host} golang:1.6 go run signup.go -v


cat > /usr/share/nginx/html/index.html << "EOF"
<html>
  <head>
    <title>Frontend NGINX</title>
  </head>
  <body>
    <center><h2>NGINX server</h2></center><br>
    <center>Status: running</center>
    <center>by: Berenice V. Cotero</center>
  </body>
</html>
EOF
