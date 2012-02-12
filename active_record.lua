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
-- local products = Product.findAll
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

local radlib = require 'radlib'

require 'middleclass'

ActiveRecord = class('ActiveRecord')

------------------------------------------------------------------------------
-- CLASS (STATIC) METHODS - START
------------------------------------------------------------------------------

function ActiveRecord:initialize(newRecord)
  for k in pairs(self.tableFields) do
    self.k = newRecord.k
  end
end

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
  local record = orm.selectOne(self.tableName, 'id', id)
  --setmetatable( record, ActiveRecord )
  --return record
  local result = ActiveRecord:new(record)
  return result
end

------------------------------------------------------------------------------
-- Returns all rows in the table.
------------------------------------------------------------------------------
function ActiveRecord.static:findAll()
  return orm.selectAll(self.tableName)
end

------------------------------------------------------------------------------
-- CLASS (STATIC) METHODS - END
------------------------------------------------------------------------------




------------------------------------------------------------------------------
-- INSTANCE METHODS - START
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Updates one column value
------------------------------------------------------------------------------
function ActiveRecord:updateAttribute( columnName, columnValue )
  local filter = "id = " .. self.id
  orm.updateAttribute( self.tableName, filter, columnName, columnValue )
end

------------------------------------------------------------------------------
-- INSTANCE METHODS - END
------------------------------------------------------------------------------



