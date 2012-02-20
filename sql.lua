------------------------------------------------------------------------------
-- Module for SQL generation
------------------------------------------------------------------------------
local _ = require 'underscore'
local string_ext = require 'string_ext'

local M = {}
------------------------------------------------------------------------------
-- Generate the sql for the given field def flags
------------------------------------------------------------------------------
local sqlForFieldFlags = function(fieldDef)
  if fieldDef.flags ~= nil then
    return _.join(fieldDef.flags, ' '):upper()
  else
    return ''
  end
end
M.sqlForFieldFlags = sqlForFieldFlags

------------------------------------------------------------------------------
-- Generate a CREATE TABLE IF NOT EXISTS statement
-- for the given tablename and tablefield definitions
------------------------------------------------------------------------------
local generateCreateTable = function(tableName, tableFields)
  print("Creating " .. tableName)
  local result = ''
  result = 'CREATE TABLE IF NOT EXISTS ' .. tableName .. '('
  for fieldName,fieldDef in pairs(tableFields) do
    result = result .. string_ext.doubleQuote(fieldName) .. ' ' .. fieldDef.dataType:upper()
    result = result .. ' ' .. M.sqlForFieldFlags(fieldDef)
    result = result .. ','
  end
  result = string.sub( result, 1, result:len()-1 )
  result = result .. ')'
  return result
end
M.generateCreateTable = generateCreateTable

return M
