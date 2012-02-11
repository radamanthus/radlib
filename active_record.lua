-- USAGE
--
-- Create a Lua file for your module. The file should look like this:
--
-- require 'ActiveRecord'
-- Product = ActiveRecord:subclass('ActiveRecord')
-- Product.tableName = 'products'
-- Product.tableFields = {
--  id = {type = 'integer', flags = {'primary_key', 'autoincrement', 'not_null'} },
--  name = {type = 'string', flags = {'not_null'} }
-- }
--
-- If the table does not yet exist, you can create it in your app initialization with this call:
--
-- orm.initialize()
-- Product.createTable()
--
-- Sample API calls
--
-- local products = Product.findAll (NOT YET IMPLEMENTED)
--
-- p = Product.new{id = 1, name = 'test', description = ''} (NOT YET IMPLEMENTED)
-- p.save
--
-- p.updateAttribute('name', 'newName')
-- p.updateAttributes{name = 'newName', description = 'newDescription'} (NOT YET IMPLEMENTED)
--
-- p = Product.find(1)
-- test_products = Product.where("name = 'test'")
--
-- numberOfProducts = Product.count()
--

require 'middleclass'

ActiveRecord = class('ActiveRecord')
ActiveRecord.static.tableName = 'users'

------------------------------------------------------------------------------
-- Returns the number of rows in the table
------------------------------------------------------------------------------
function ActiveRecord.static:count()
  return orm.getTableRowCount(self.tableName)
end

------------------------------------------------------------------------------
-- Returns the record matching the given id. Returns nil if no match is found.
------------------------------------------------------------------------------
function ActiveRecord.static:find(id)
  return orm.selectOne(self.tableName, 'id', id)
end

------------------------------------------------------------------------------
-- Returns all rows in the table.
------------------------------------------------------------------------------
function ActiveRecord.static:findAll()
  return orm.selectAll(self.tableName)
end

