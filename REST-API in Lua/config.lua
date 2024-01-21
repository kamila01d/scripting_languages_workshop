local config = require("lapis.config")

config("development", {
  port = 8080,
  -- Database configuration
  postgres = {
    host = "127.0.0.1",
    user = "myuser",
    password = "mypassword",
    database = "mydatabase"
  }
})

config("production", {
  port = 80,
  -- Production database configuration
  postgres = {
    host = "127.0.0.1",
    user = "myuser",
    password = "mypassword",
    database = "mydatabase"
  }
})
