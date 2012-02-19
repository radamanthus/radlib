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

require 'middleclass'

ActiveRecord = class('ActiveRecord')

------------------------------------------------------------------------------
-- CLASS (STATIC) METHODS - START
------------------------------------------------------------------------------
function ActiveRecord:initialize(newRecord)
  for k,v in pairs(newRecord) do
    self[k] = v
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
--
-- NOTE: Until I figure out how to determine the caller's class,
-- I'll have to resort to this ugliness of using the klass parameter
------------------------------------------------------------------------------
function ActiveRecord.static:find(klass, id)
  local record = orm.selectOne(klass.tableName, 'id', id)
  if not( record == nil ) then
    result = klass:new(record)
  end
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
-- Reloads the record values from the database
------------------------------------------------------------------------------
function ActiveRecord:reload()
  local updatedRecord = orm.selectOne( self.class.tableName, 'id', self.id )
  for k,v in pairs(updatedRecord) do
    self[k] = v
  end
end

------------------------------------------------------------------------------
-- Saves the content of the object to the database.
-- If a matching record already exists in the database, an UPDATE is done.
-- Otherwise an INSERT is done.
------------------------------------------------------------------------------
function ActiveRecord:save()
  print("IMPLEMENTATION PENDING...")
end

------------------------------------------------------------------------------
-- Updates one column value
------------------------------------------------------------------------------
function ActiveRecord:updateAttribute( columnName, columnValue )
  local filter = "id = " .. self.id
  orm.updateAttribute( self.class.tableName, filter, columnName, columnValue )
end

------------------------------------------------------------------------------
-- Updates an array of columns
------------------------------------------------------------------------------
function ActiveRecord:updateAttributes( updateTable )
  print("IMPLEMENTATION PENDING...")
end

------------------------------------------------------------------------------
-- INSTANCE METHODS - END
------------------------------------------------------------------------------



