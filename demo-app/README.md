### Golang demo app with MySQL database 

#### Requires: 

* [golang.org/x/crypto/bcrypt](https://godoc.org/golang.org/x/crypto/bcrypt)

* [github.com/go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)

### How To Run 

```
mkdir migrations
>>> put sql file here <<<
export MYSQL_PASSWORD=pass; export MYSQL_USER=usuario; export MYSQL_DATABASE=login-app; export MYSQL_HOST=172.31.69.168
migrate -url mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST/$MYSQL_DATABASE -path ./migrations create migration_signup_example
migrate -url mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST/$MYSQL_DATABASE -path ./migrations up
```

```sql
CREATE TABLE users(
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(120)
);
```
