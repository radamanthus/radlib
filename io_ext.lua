local http = require("socket.http")
local ltn12 = require("ltn12")

local M = {}

-- Taken from http://stackoverflow.com/questions/4990990/lua-check-if-a-file-exists
local fileExists = function( filename )
   local f = io.open( filename, "r" )
   if f ~= nil then io.close( f ) return true else return false end
end
M.fileExists = fileExists

local json = require "json"
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

local parseRemoteJson = function( remoteUrl )
  local tempFilename = system.pathForFile( "temp.json", system.TemporaryDirectory )
  local tempFile = io.open( tempFilename, "w+b" )

  http.request {
    url = remoteUrl,
    sink = ltn12.sink.file( tempFile )
  }

  return parseJson( tempFilename )
end
M.parseRemoteJson = parseRemoteJson

return M

