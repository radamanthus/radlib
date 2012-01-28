-- This is a sample Lua file that demonstrates how to use active_record
-- You don't need to include this in your app when you use radlib
local Product = require 'active_record'
Product.setTableName('users')

return Product
