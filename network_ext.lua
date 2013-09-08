local M = {}
M.network = {}

-- from Naomi and Andrew in http://forums.coronalabs.com/topic/33356-check-for-internet-connection/
local hasNetworkConnection = function( url, port )
  local socket = require("socket")
  local test = socket.tcp()
  test:settimeout(1000)  -- Set timeout to 1 second
  local netConn = test:connect( url, port )
  if netConn == nil then
    return false
  end
  test:close()
  return true
end
M.hasNetworkConnection = hasNetworkConnection

return M

