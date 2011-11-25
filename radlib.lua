-- Rad's Library of awesome Lua functions to complement the awesome Corona SDK

local M = {}


local tableExt = require "table_ext"
M.table = tableExt

local ioExt = require "io_ext"
M.io = ioExt


local debug = function( msg )
  native.showAlert("DEBUG", msg, {"OK"})
end
M.debug = debug

return M



