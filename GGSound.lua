-- Project: GGSound
--
-- Date: September 5, 2012
--
-- Version: 0.1
--
-- File name: GGSound.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Update History:
--
-- 0.1 - Initial release
--
-- Comments: 
-- 
--		GGSound allows for easy management of sound effects and global volume in your Corona SDK powered apps.
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGSound = {}
local GGSound_mt = { __index = GGSound }

--- Initiates a new GGSound object.
-- @param channels A table containing what channels have been reserved for this sound library.
-- @return The new object.
function GGSound:new( channels )
    
    local self = {}
    
    setmetatable( self, GGSound_mt )
    	
    self.sounds = {}
    self.volume = 1
    self.enabled = true
    
    self.channels = channels
    
    return self
    
end

--- Adds a sound file to this sound library.
-- @param pathOrHandle The path to the sound file or a pre-loaded sound handle.
-- @param name The name of the sound.
-- @param baseDirectory The base directory of the sound. Optional, defaults to system.ResourceDirectory.
function GGSound:add( pathOrHandle, name, baseDirectory )

	self.sounds = self.sounds or {}
	
	if type( pathOrHandle ) == "string" then
		pathOrHandle = audio.loadSound( pathOrHandle, baseDirectory or system.ResourceDirectory )
	end
	self.sounds[ name ] = {}
	self.sounds[ name ].handle = pathOrHandle
	
end

-- Removes a sound from the library and destroys it.
-- @param name The name of the sound.
function GGSound:remove( name )

	if not self.sounds or not self.sounds[ name ] then
		return
	end
	
	if self.sounds[ name ].channel then
		audio.stop( self.sounds[ name ].channel )
	end
	
	if self.sounds[ name ].handle then
		audio.dispose( self.sounds[ name ].handle )
	end
	
	self.sounds[ name ] = nil
	
end

--- Plays a pre-added sound file.
-- @param name The name of the sound.
-- @param options The options for the sound, optional.
function GGSound:play( name, options )

	if not self.sounds or not self.sounds[ name ] or not self.sounds[ name ].handle then
		return
	end
	
	if not self.enabled then
		return
	end
	
	local options = options or {}
	
	options.channel = self:findFreeChannel()
	
	if options.channel then
		audio.setVolume( self.volume, { channel = options.channel } )
		self.sounds[ name ].channel = audio.play( self.sounds[ name ].handle, options )
	end
	
end

--- Sets the volume of the sound library.
-- @param volume The new volume.
function GGSound:setVolume( volume )
	
	self.volume = volume
	
	if self.volume > 1 then
		self.volume = 1
	elseif self.volume < 0 then
		self.volume = 0
	end
	
	for i = 1, #self.channels, 1 do
		audio.setVolume( self.volume, { channel = self.channels[ i ] } )
	end
	
end

--- Gets the volume of the sound library.
-- @return The volume.
function GGSound:getVolume()
	return self.volume
end

--- Finds a free channel.
-- @return The channel number. Nil if none found.
function GGSound:findFreeChannel()

	if self.channels then
		for i = 1, #self.channels, 1 do
			if not audio.isChannelActive( self.channels[ i ] ) then
				return self.channels[ i ]
			end
		end
	else
		return audio.findFreeChannel()
	end
	
end

--- Removes all loaded sounds and destroys them.
function GGSound:removeAll()

	self:stopAll()
	
	for k, v in pairs( self.sounds ) do
		if v then
			audio.dispose( v.handle )
		end
		v.handle = nil
	end
	self.sounds = {}
	
end

--- Stops all currently active sounds.
function GGSound:stopAll()
	if self.channels then
		for i = 1, #self.channels, 1 do
			audio.stop( self.channels[ i ] )
		end
	end
end

--- Destroys this GGSound object.
function GGSound:destroy()

	self:stopAll()
	self:removeAll()

	self.sounds = nil
	
end

return GGSound
