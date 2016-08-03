### Golang demo app with mysql db 

#### Requires: 

* ![golang.org/x/crypto/bcrypt](https://godoc.org/golang.org/x/crypto/bcrypt)

* ![github.com/go-sql-driver/mysql](https://github.com/go-sql-driver/mysql)

### How To Run 

```
mkdir migrations
>>> put sql file here <<<
export MYSQL_PASSWORD=bookings; export MYSQL_USER=bookings; export MYSQL_DATABASE=bookings; export MYSQL_HOST=127.0.0.1
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
