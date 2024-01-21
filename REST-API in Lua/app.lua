local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local json_params = require("lapis.application").json_params
local app = lapis.Application()

-- Define the models
local Categories = Model:extend("categories", {
  primary_key = "id"
})

local Products = Model:extend("products", {
  primary_key = "id",
  relations = {
    { "category", belongs_to = "Categories" }
  }
})


app:match("/categories", {
    GET = function(self)
        -- Code to list categories
    end,

    POST = json_params(function(self)
        -- Create a new category
        local category = Categories:create {
            name = self.params.name
        }
        return { json = category }
    end)
})

-- CRUD operations for products under a category
app:match("/categories/:category_id/products", {
  GET = function(self)
    -- Read all products in a category
    local products = Products:select("where category_id = ?", self.params.category_id)
    return { json = products }
  end,

  POST = json_params(function(self)
    -- Create a new product
    local product = Products:create {
      name = self.params.name,
      price = self.params.price,
      category_id = self.params.category_id
    }
    return { json = product }
  end)
})

app:match("/categories/:category_id/products/:id", {
  GET = function(self)
    -- Read a single product
    local product = Products:find(self.params.id)
    if product then
      return { json = product }
    else
      return { status = 404, json = { error = "Product not found" } }
    end
  end,

  PUT = json_params(function(self)
    -- Update a product
    local product = Products:find(self.params.id)
    if product then
      product:update {
        name = self.params.name,
        price = self.params.price
      }
      return { json = product }
    else
      return { status = 404, json = { error = "Product not found" } }
    end
  end),

  DELETE = function(self)
    -- Delete a product
    local product = Products:find(self.params.id)
    if product then
      product:delete()
      return { json = { status = "success" } }
    else
      return { status = 404, json = { error = "Product not found" } }
    end
  end
})

return app
