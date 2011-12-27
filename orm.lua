local sqlite3 = require "sqlite3"

local radlib = require "radlib"

local path = system.pathForFile("data.db", system.DocumentsDirectory)
local db = sqlite3.open( path )

local M = {}

------------------------------------------------------------------------------
-- Close the database
------------------------------------------------------------------------------
local close = function()
  db:close()
end
M.close = close

------------------------------------------------------------------------------
-- Return all the contents of an SQLite table as a table structure
------------------------------------------------------------------------------
local selectAll = function(tableName)
  local result = {}
  for row in db:nrows("SELECT * FROM " .. tableName) do
    result[#result+1] = row
  end
  return result
end
M.selectAll = selectAll

------------------------------------------------------------------------------
-- Return contents of an SQLite table filtered by a WHERE query
-- Return value is a table structure
------------------------------------------------------------------------------
local selectWhere = function(tableName, whereClause)
  local result = {}
  for row in db:nrows("SELECT * FROM " .. tableName .. " " .. whereClause) do
    result[#result+1] = row
  end
  return result
end
M.selectWhere = selectWhere

------------------------------------------------------------------------------
-- Return the row from the given table,
-- selected from the given key/keyValue pair
------------------------------------------------------------------------------
local selectOne = function(tableName, key, keyValue)
  local result = {}
  for row in db:nrows(
		"SELECT * FROM " .. tableName ..
		" WHERE " .. key .. " = " .. keyValue ..
		" LIMIT 1") do
    result[1] = row
    break
  end
  return result[1]
end
M.selectOne = selectOne

------------------------------------------------------------------------------
-- If a matching id already exists in the database, do an update
-- otherwise do an insert
------------------------------------------------------------------------------
local createOrUpdate = function( tableName, recordData )
  M.insertRow( tableName, recordData )
end
M.createOrUpdate = createOrUpdate

------------------------------------------------------------------------------
-- Returns the number of rows for the given table
------------------------------------------------------------------------------
local getTableRowCount = function(tableName)
  local rowCount = 0
  for row in db:nrows("SELECT COUNT(*) as rowcount FROM " .. tableName) do
    rowCount = row.rowcount
  end
  return rowCount
end
M.getTableRowCount = getTableRowCount

------------------------------------------------------------------------------
-- Inserts a row into the given table
------------------------------------------------------------------------------
local insertRow = function( tableName, row )
  -- temporary holding variables
  local columnList = " ( "
  local valuesList = " VALUES("

  -- format column values into SQL-safe strings
  -- then concatenate them together
  for i,v in pairs(row) do
    local colName = i
    local colValue = v
    if type(v) == 'string' then
      colValue = radlib.string.toSqlString(v)
    end
    columnList = columnList .. colName .. ","
    valuesList = valuesList .. colValue .. ","
  end

  -- strip off the trailing comma and add a closing parentheses
  columnList = string.sub( columnList, 1, columnList:len()-1 ) .. ')'
  valuesList = string.sub( valuesList, 1, valuesList:len()-1 ) .. ')'

  -- prepare the complete SQL command
  local sql = "INSERT INTO " .. tableName .. columnList .. valuesList

  -- execute the SQL command for inserting the row
  print("Running INSERT SQL: " .. sql)
  db:exec( sql )
end
M.insertRow = insertRow

------------------------------------------------------------------------------
-- Updates one column for one row in a given table
------------------------------------------------------------------------------
local updateAttribute = function( tablename, filter, columnName, columnValue )
  local updateStr = "UPDATE " .. tablename ..
    " SET " .. columnName .. " = " .. columnValue ..
    " WHERE " .. filter
  print("UPDATE SQL: " .. updateStr )
  db:exec( updateStr )
end
M.updateAttribute = updateAttribute

------------------------------------------------------------------------------
-- Updates multiple columns for one row in a given table
------------------------------------------------------------------------------
local updateAttributes = function( tablename, filter, columns, columnValues )
  local updateStr = ''
  radlib.table.print(object)
  for i,v in ipairs(columns) do
    updateStr = v .. " = " .. columnValues[i]
    if i < #columns then
      updateStr = updateStr .. ", "
    end
  end
  print("UPDATE SQL: " .. updateStr)
  db:exec(
    "UPDATE " .. tablename .. " SET " ..
    updateStr ..
    " WHERE " .. filter
  )
end
M.updateAttributes = updateAttributes

return M

