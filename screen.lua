local M = {}

------------------------------------------------------------------------------
-- Center the given object's position along the X-axis
------------------------------------------------------------------------------
local centerX = function( object )
  object.x = object.x - object.contentWidth/2
end
M.centerX = centerX

------------------------------------------------------------------------------
-- Center the given object's position along the Y-axis
------------------------------------------------------------------------------
local centerY = function( object )
  object.y = object.y - object.contentHeight/2
end
M.centerY = centerY

return M


