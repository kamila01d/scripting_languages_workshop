local db = require("lapis.db")

return {
  [1] = function()

    db.query([[
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL
      )
    ]])
  end,

  [2] = function()
    -- Create products table
    db.query([[
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price NUMERIC NOT NULL,
        category_id INTEGER REFERENCES categories(id)
      )
    ]])
  end,
}
