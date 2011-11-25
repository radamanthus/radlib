local M = {}

require "json"
local parseJson = function( filename )
  local file = io.open( filename, "r" )
  if file then
    local contents = file:read( "*a" )
    result = json.decode( contents )
    io.close( file )
    return result
  else
    return {}
  end
end
M.parseJson = parseJson

return M
