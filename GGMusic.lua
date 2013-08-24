-- Project: GGMusic
--
-- Date: September 4, 2012
--
-- Version: 0.1
--
-- File name: GGMusic.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Update History:
--
-- 0.1 - Initial release
--
-- Comments: 
--
--		GGMusic allows you to play a list of background music tracks in linear or random 
--		order in your Corona SDK powered apps.
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

local GGMusic = {}
local GGMusic_mt = { __index = GGMusic }

--- Initiates a new GGMusic object.
-- @return The new object.
function GGMusic:new()
    
    local self = {}
    
    setmetatable( self, GGMusic_mt )
    	
    self.tracks = {}
    
    self.currentIndex = nil
    self.currentTrack = nil
    
    self.random = false
    self.loop = true
    
    self.channel = audio.findFreeChannel()
    self.volume = 1
    
    self.enabled = true
     
    return self
    
end

--- Adds a track to the music library.
-- @param pathOrHandle Either the path to the music file or the already loaded sound/stream handle.
-- @param name The name of the track, used for easy access. Optional.
-- @return The index for the newly added track as well as the name if provided ( in case it was created dynamically ).
-- @param baseDirectory The base directory of the music file. Optional, defaults to system.ResourceDirectory.
function GGMusic:add( pathOrHandle, name, baseDirectory )
	
	self.tracks[ #self.tracks + 1 ] = 
	{ 
		path = pathOrHandle,
		handle = pathOrHandle,
		baseDirectory = baseDirectory or system.ResourceDirectory,
		name = name 
	}

	if #self.tracks == 1 then
		self.currentTrack = self.tracks[ 1 ]
		self.currentIndex = 1
	end
	
	if self.random then
		self.currentTrack = self.tracks[ math.random( 1, #self.tracks ) ]
	end
	
	return #self.tracks, name
	
end

--- Fades out the volume of the currently playing track. When complete the track will be stopped and the volume reset.
-- @param time The duration of the fadeout. Optional, defaults to 500.
-- @param onComplete Function to be called when the fade is complete. Optional.
function GGMusic:fadeOut( time, onComplete )

	time = time or 500
	
	local t
	
	local onComplete = function()
		if t then timer.cancel( t ) end
		t = nil
		self:stop()
		self:setVolume( self.volume )
		if onComplete then onComplete() end
	end
	
	audio.fadeOut{ channel = self.channel, time = time }
	
	t = timer.performWithDelay( time, onComplete, 1 )
	
end

--- Stops the current track and jumps to the next one. The next track will be random if .random is set to true.
-- @param onComplete Function to be called when the track is complete. Optional. If the onComplete function returns true, the next track won't play.
function GGMusic:next( onComplete )
	
	local previousIndex = self.currentIndex
	local nextIndex = self.currentIndex
	
	if self.random then
		if #self.tracks > 1 then
			while nextIndex == self.currentIndex do
				nextIndex = math.random( 1, #self.tracks )
			end
		else
			nextIndex = 1
		end
	else
		nextIndex = self.currentIndex + 1
	end
	
	if previousIndex == nextIndex then
		nextIndex = nextIndex + 1
	end
	
	if nextIndex > #self.tracks then
		if self.random or self.loop then
			nextIndex = 1
		else
			return
		end
	end
	
	self.currentIndex = nextIndex
	
	self.currentTrack = self.tracks[ self.currentIndex ]
	
	self:stop()
	self:play( nil, onComplete )
	
end

--- Pauses the currently playing track.
function GGMusic:pause()
	audio.pause( self.channel )
end

--- Starts playing the current track. If one is already playing it will be stopped immediately.
-- @param name The name of the track to play. Optional.
-- @param onComplete Function to be called when the track is complete. Optional. If the onComplete function returns true, the next track won't play.
function GGMusic:play( name, onComplete )
	
	if not self.enabled then
		return
	end
	
	local onTrackComplete = function( event )
	
		local handled = false
		
		if onComplete then
			handled = onComplete( event )
		end
		
		if not handled and event.completed then
			self:next()
		end
		
	end
	
	local track = self.currentTrack
	
	if name then
		for i = 1, #self.tracks, 1 do
			if self.tracks[ i ].name == name then
				track = self.tracks[ i ]
				break
			end
		end	
	end
	
	if track then
	
		local options = 
		{ 
			channel = self.channel 
		}
		
		if not track.handle or type( track.handle ) == "string" then			
			track.handle = audio.loadStream( track.path, track.baseDirectory )
		end
		
		options.onComplete = onTrackComplete
		
		audio.stop( self.channel )
		audio.play( track.handle, options )
		
	end
	
end

--- Sets the volume of the music library.
-- @param volume The new volume.
function GGMusic:setVolume( volume )
	self.volume = volume
	audio.setVolume( self.volume, { channel = self.channel } )
end

--- Gets the volume of the music library.
-- @return The volume.
function GGMusic:getVolume()
	return self.volume
end

--- Stops the currently playing track and rewinds it back to beginning.
function GGMusic:stop()
	audio.rewind( self.channel ) 
	audio.stop( self.channel )
end

--- Destroys this GGMusic object.
function GGMusic:destroy()

	self:stop()
	
	for i = 1, #self.tracks, 1 do
		if self.tracks[ i ].handle then
			audio.dispose( self.tracks[ i ].handle )
		end
		self.tracks[ i ].handle = nil
		self.tracks[ i ] = nil
	end
	
	self.tracks = nil
	self = nil
	
end

return GGMusic
