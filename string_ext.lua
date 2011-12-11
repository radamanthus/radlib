local M = {}
M.string = {}

local doublequote = function( str )
  return '"' .. str .. '"'
end
M.doublequote = doublequote

local singlequote = function( str )
  return "'" .. str .. "'"
end
M.singlequote = singlequote

local toSqlString = function( str )
  local result = string.gsub( str, "'", "'''")
  result = singleQuote( result )
  return result
end
M.toSqlString = toSqlString

return M
