package main

import "os"
import "fmt"
import "database/sql"
import _ "github.com/go-sql-driver/mysql"

import "golang.org/x/crypto/bcrypt"

import "net/http"

var db *sql.DB
var err error

func signupPage(res http.ResponseWriter, req *http.Request) {
	if req.Method != "POST" {
		http.ServeFile(res, req, "signup.html")
		return
	}

	username := req.FormValue("username")
	password := req.FormValue("password")

	var user string

	err := db.QueryRow("SELECT username FROM users WHERE username=?", username).Scan(&user)

	switch {
	case err == sql.ErrNoRows:
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			http.Error(res, "Server error, unable to create your account.", 500)
			return
		}

		_, err = db.Exec("INSERT INTO users(username, password) VALUES(?, ?)", username, hashedPassword)
		if err != nil {
			http.Error(res, "Server error, unable to create your account.", 500)
			return
		}

		res.Write([]byte("User created!"))
		return
	case err != nil:
		http.Error(res, "Server error, unable to create your account.", 500)
		return
	default:
		http.Redirect(res, req, "/", 301)
	}
}

func loginPage(res http.ResponseWriter, req *http.Request) {
	if req.Method != "POST" {
		http.ServeFile(res, req, "login.html")
		return
	}

	username := req.FormValue("username")
	password := req.FormValue("password")

	var databaseUsername string
	var databasePassword string

	err := db.QueryRow("SELECT username, password FROM users WHERE username=?", username).Scan(&databaseUsername, &databasePassword)

	if err != nil {
		http.Redirect(res, req, "/login", 301)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(databasePassword), []byte(password))
	if err != nil {
		http.Redirect(res, req, "/login", 301)
		return
	}

	res.Write([]byte("Hello " + databaseUsername + "!"))
	res.Write([]byte(" Welcome to the Demo Application!"))

}

func homePage(res http.ResponseWriter, req *http.Request) {
	http.ServeFile(res, req, "index.html")
}

func main() {

  db_user  := os.Getenv("MYSQL_USER")
  db_password := os.Getenv("MYSQL_PASSWORD")
  db_name  := os.Getenv("MYSQL_DATABASE")
  db_host  := os.Getenv("MYSQL_HOST")

  access_url := db_user + ":" + db_password + "@tcp(" + db_host + ":3306)/" + db_name
  fmt.Println(access_url)
  db, err = sql.Open("mysql", access_url)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err.Error())
	}

	http.HandleFunc("/demo-app/signup", signupPage)
	http.HandleFunc("/demo-app/login", loginPage)
	http.HandleFunc("/demo-app", homePage)
	http.ListenAndServe(":8080", nil)
}
