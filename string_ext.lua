local M = {}
M.string = {}

local doublequote = function( str )
  return '"' .. str .. '"'
end
M.string.doublequote = doublequote

local singlequote = function( str )
  return "'" .. str .. "'"
end
M.string.singlequote = singlequote

local toSqlString = function( str )
  local result = string.gsub( str, "'", "'''")
  result = singleQuote( result )
  return result
end
M.string.toSqlString = toSqlString

return M
