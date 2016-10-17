#!/bin/bash

export GOPATH=/home/ec2-user/go
export APP_DIR=/home/ec2-user/demo-app

sudo yum install -y nginx docker
sudo usermod -a -G docker ec2-user
sudo service docker restart

# Config file for nginx

cat > /etc/nginx/nginx.conf << "EOF"
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    index   index.html index.htm;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  localhost;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        location /demo-app {
            proxy_pass http://localhost:8080;
        }
    }
}
EOF

sudo service nginx restart

# Simple home page
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
docker run --rm -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -w /usr/src/myapp  \
  golang:1.6 migrate \
  -url mysql://$MYSQL_USER:$MYSQL_PASSWORD@tcp\($MYSQL_HOST:3306\)/$MYSQL_DATABASE \
  -path migrations up

# Run the app
docker run --rm -v $APP_DIR:/usr/src/myapp \
  -v "$GOPATH":/go \
  -e MYSQL_PASSWORD=pass \
  -e MYSQL_USER=usuario \
  -e MYSQL_DATABASE=login-app \
  -e MYSQL_HOST=${db_host} \
  -p 8080:8080 \
  -w /usr/src/myapp \
  golang:1.6 go run signup.go -v

