local http = require("socket.http")
local ltn12 = require("ltn12")

local M = {}

-- From http://docs.coronalabs.com/api/type/File/write.html
local copyFile = function( srcName, srcPath, dstName, dstPath, overwrite )
  local results = true                -- assume no errors

  -- Copy the source file to the destination file
  local rfilePath = system.pathForFile( srcName, srcPath )
  local wfilePath = system.pathForFile( dstName, dstPath )

  local rfh = io.open( rfilePath, "rb" )
  local wfh = io.open( wfilePath, "wb" )

  if  not wfh then
    print( "writeFileName open error!" )
    results = false -- error
  else
    -- Read the file from the Resource directory and write it to the destination directory
    local data = rfh:read( "*a" )

    if not data then
      print( "read error!" )
      results = false     -- error
    else
      if not wfh:write( data ) then
        print( "write error!" )
        results = false -- error
      end
    end
  end

  -- Clean up our file handles
  rfh:close()
  wfh:close()

  return results
end
M.copyFile = copyFile

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

