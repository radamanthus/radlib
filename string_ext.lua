local M = {}
M.string = {}

local doublequote = function( str )
  return '"' .. str .. '"'
end
M.doublequote = doublequote
M.doubleQuote = doublequote

local singlequote = function( str )
  return "'" .. str .. "'"
end
M.singlequote = singlequote
M.singleQuote = singlequote

local toSqlString = function( str )
  local result = string.gsub( str, "'", "'''")
  result = singleQuote( result )
  return result
end
M.toSqlString = toSqlString

return M
