--
-- local products = Product.findAll
--
-- p = Product.new{id = 1, name = 'test', description = ''}
-- p.save
--
-- p.updateAttribute('name', 'newName')
-- p.updateAttributes{name = 'newName', description = 'newDescription'}
--
--
-- p = Product.find(1)
-- test_products = Product.where("name = 'test'")
--
-- numberOfProducts = Product.count()
--
--
-- USAGE
--
-- Create a Lua file for your module. The file should look like this:
--
-- local Product = require 'active_record'
-- Product.setTableName('products')
-- Product.setTableFields({
--  id = {type = 'integer', flags = {'primary_key', 'autoincrement', 'not_null'} },
--  name = {type = 'string', flags = {'not_null'} }
-- })
-- return Product
--
-- If the table does not yet exist, you can create it in your app initialization with this call:
--
-- orm.initialize()
-- Product.createTable()

local M = {}

------------------------------------------------------------------------------
-- Returns the number of rows in the table
------------------------------------------------------------------------------
local count = function()
  return orm.getTableRowCount(M.tableName)
end
M.count = count

------------------------------------------------------------------------------
-- Returns the record matching the given id. Returns nil if no match is found.
------------------------------------------------------------------------------
local find = function(id)
  return orm.selectOne(M.tableName, 'id', id)
end
M.find = find

------------------------------------------------------------------------------
-- Returns all rows in the table.
------------------------------------------------------------------------------
local findAll = function()
  return orm.selectAll(M.tableName)
end
M.findAll = findAll

------------------------------------------------------------------------------
-- Sets the database table name for this class
------------------------------------------------------------------------------
local setTableName = function(tableName)
  M.tableName = tableName
end
M.setTableName = setTableName

------------------------------------------------------------------------------
-- Sets the database table fields for this class
------------------------------------------------------------------------------
local setTableFields = function(tableFields)
  M.tableFields = tableFields
end
M.setTableFields = setTableFields

return M
