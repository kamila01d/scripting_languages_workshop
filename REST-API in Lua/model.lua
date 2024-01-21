local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Categories = Model:extend("categories", {
  primary_key = "id"
})

local Products = Model:extend("products", {
  primary_key = "id",
  relations = {
    { "category", belongs_to = "Categories" }
  }
})
