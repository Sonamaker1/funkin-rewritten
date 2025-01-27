--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local titleBG = Image(love.graphics.newImage(graphics.imagePath("menu/title-bg")))
local logo = Image(love.graphics.newImage(graphics.imagePath("menu/logo")))

local girlfriendTitle = love.filesystem.load("sprites/menu/girlfriend-title.lua")()

-- 4 weeks, plus tutorial week = 5 weeks
local maxNumberOfWeeks = 5 

local storyMenuImages = { 
	{}, --tutorial
	{}, --Week 1
	{}, --Week 2
	{}, --Week 3
	{}, --Week 4
	{}, --Week 5 placeholder
}

local weekIDs = {
	"Tutorial",
	"Week 1",
	"Week 2",
	"Week 3",
	"Week 4",
	--"Week 5"
}

for i = 1, maxNumberOfWeeks do
	local o = Image(love.graphics.newImage(graphics.imagePath("menu/week" .. (i-1))))
	o.x = 0
	o.y = 300
	storyMenuImages[i] = o
end

local weekSongs = {
	{
		"Tutorial"
	},
	{
		"Bopeebo",
		"Fresh",
		"Dadbattle"
	},
	{
		"Spookeez",
		"South"
	},
	{
		"Pico",
		"Philly Nice",
		"Blammed"
	},
	{
		"Satin Panties",
		"High",
		"M.I.L.F"
	}

}
local difficultyStrs = {
	"-easy",
	"",
	"-hard"
}

local selectSound = love.audio.newSource("sounds/menu/select.ogg", "static")
local confirmSound = love.audio.newSource("sounds/menu/confirm.ogg", "static")

local music = love.audio.newSource("music/menu/menu.ogg", "stream")

logo.x, logo.y = -350, -125
logo.sizeX, logo.sizeY = 1.25, 1.25

local gfTitleScale=0.80
girlfriendTitle.x, girlfriendTitle.y = 300*(1/gfTitleScale), -160*(1/gfTitleScale)

music:setLooping(true)

local alpha=1.0
local oldOption=1
menu = {
	load = function()
		gameOver = false
		storyMode = false
		
		inGame = false
		inOptions = false
		inMenu = true
		
		songNum = 0
		menuState = 0
		
		music:play()
	end,
	
	update = function(dt)
		girlfriendTitle:update(dt)
		
		local quickInputs = {
			left = input:pressed("left"),
			right = input:pressed("right"),
			up = input:pressed("up"),
			down = input:pressed("down"),
			confirm = input:pressed("confirm"),
			back = input:pressed("back")
		}

		if menuState > 0 then
			quickInputs.left  = quickInputs.left or quickInputs.up
			quickInputs.right = quickInputs.right or quickInputs.down 
		end

		if not graphics.isFading then
			if quickInputs.left then
				audio.playSound(selectSound)
				alpha=1
				oldOption=weekNum
				if menuState == 2 then
					songDifficulty = songDifficulty - 1
					
					if songDifficulty < 1 then
						songDifficulty = 3
					end
				elseif menuState == 1 then
					songNum = songNum - 1
					
					if songNum < 0 then
						songNum = #weekSongs[weekNum]
					end
				elseif menuState == 0 then
					weekNum = weekNum - 1
					
					if weekNum < 1 then
						weekNum = maxNumberOfWeeks
					end
				end
			elseif quickInputs.right then
				audio.playSound(selectSound)
				alpha=1
				oldOption=weekNum
				if menuState == 2 then
					songDifficulty = songDifficulty + 1
					
					if songDifficulty > 3 then
						songDifficulty = 1
					end
				elseif menuState == 1 then
					songNum = songNum + 1
					
					if songNum > #weekSongs[weekNum] then
						songNum = 0
					end
				elseif menuState == 0 then
					weekNum = weekNum + 1
					
					if weekNum > maxNumberOfWeeks then
						weekNum = 1
					end
				end
			elseif quickInputs.confirm then
				audio.playSound(confirmSound)
				
				menuState = menuState + 1
				
				if menuState > 2 then
					music:stop()
					
					menuState = 2 -- So menuState isn't an "invalid" value
					
					graphics.fadeOut(
						1,
						function()
							songAppend = difficultyStrs[songDifficulty]
							
							inMenu = false
							inOptions = false
							inGame = true
							
							if songNum == 0 then
								songNum = 1
								storyMode = true
							end
							
							weekData[weekNum].init()
						end
					)
				end
			elseif quickInputs.back then
				if menuState > 0 then -- Don't play sound if exiting the game
					audio.playSound(selectSound)
				end
				
				menuState = menuState - 1
				
				if menuState == 0 then
					songNum = 0
				elseif menuState < 0 then
					menuState = 0 -- So menuState isn't an "invalid" value
					
					graphics.fadeOut(1, love.event.quit)
				end
			end
		end
	end,
	
	draw = function()
		titleBG:draw()
		
		love.graphics.push()
			love.graphics.scale(cam.sizeX, cam.sizeY)
			
			logo:draw()
			
			love.graphics.push()
			love.graphics.scale(cam.sizeX*gfTitleScale, cam.sizeY*gfTitleScale)
			girlfriendTitle:draw()
			love.graphics.pop()
			
			love.graphics.printf("\t\t\tBy HTV04\t\tv1.0.0 beta 3", -625, 90, 900, "left", nil, 1, 1)
			love.graphics.printf("Original game by ninjamuffin99, PhantomArcade, \nkawaisprite, and evilsk8er, in association with Newgrounds", -625, 350, 1200, "left", nil, 1, 1)
			
			graphics.setColor(1, 1, 0)
			if menuState == 2 then
				local songName = ""
				if(songNum == 0) then
					songName = "Story Mode (Week " .. weekNum-1 .. ")"
				else
					songName = weekSongs[weekNum][songNum]
				end
				if songDifficulty == 1 then
					love.graphics.printf("Choose a difficulty:\n" .. songName .. " < Easy >", -640, 185, 853, "center", nil, 1.5, 1.5)
				elseif songDifficulty == 2 then
					love.graphics.printf("Choose a difficulty:\n" .. songName .. " < Normal >", -640, 185, 853, "center", nil, 1.5, 1.5)
				elseif songDifficulty == 3 then
					love.graphics.printf("Choose a difficulty:\n" .. songName .. " < Hard >", -640, 185, 853, "center", nil, 1.5, 1.5)
				end
			elseif menuState == 1 then
				graphics.setColor(0, 1, 1)
				love.graphics.push()
				love.graphics.translate(0,-140)
				for i = 1, #weekSongs[weekNum] do 
					local selected = i == songNum
					local sign = (function() if selected then return ' >' else return'  ' end end)()
					love.graphics.printf("" .. sign .. weekSongs[weekNum][i] , -640, 305+(i)*40, 853, "center", nil, 1.5, 1.5)
				end 
				graphics.setColor(1, 1, 0)
				local sign = (function() if songNum == 0 then return ' >' else return'  ' end end)()
				love.graphics.printf("" .. sign .. "Play Story Mode" , -640*4/3, 300, 853, "center", nil, 2, 2)

				love.graphics.pop()
				if songNum == 0 then
					love.graphics.printf("Choose a song: \n< (Story Mode) >", -640-100, 285-80, 453, "center", nil, 1.5, 1.5)
				else
					love.graphics.printf("Choose a song: \n< Freeplay: " .. weekSongs[weekNum][songNum] .. " >", -640-100, 285-80, 453, "center", nil, 1.5, 1.5)
				end
				
				
			elseif menuState == 0 then
				love.graphics.push()
				love.graphics.translate(200,-50)
				graphics.setColor(1, 1, 0)
				love.graphics.printf("Choose a week: \n < " .. weekIDs[weekNum] .. " >", -540, 265, 853, "left", nil, 1.5, 1.5)
				if(alpha>0) then
					alpha=alpha-0.1
				end
				love.graphics.setColor(1, 1, 1, alpha)
				love.graphics.push()
				love.graphics.translate(0,50-50*alpha)
				storyMenuImages[oldOption]:draw()
				love.graphics.pop()
				graphics.setColor(1, 1, 0)
				storyMenuImages[weekNum]:draw()

				love.graphics.pop()
			end
			graphics.setColor(1, 1, 1)
			
			if menuState <= 0 then
				if input:getActiveDevice() == "joy" then
					love.graphics.printf("Left Stick/D-Pad: Select | A: Confirm | B: Exit", -640, 120, 1280, "center", nil, 1, 1)
				else
					love.graphics.printf("Arrow Keys: Select | Enter: Confirm | Escape: Exit", -640, 120, 1280, "center", nil, 1, 1)
				end
			else
				if input:getActiveDevice() == "joy" then
					love.graphics.printf("Left Stick/D-Pad: Select | A: Confirm | B: Back", -640, 120, 1280, "center", nil, 1, 1)
				else
					love.graphics.printf("Arrow Keys: Select | Enter: Confirm | Escape: Back", -640, 120, 1280, "center", nil, 1, 1)
				end
			end
		love.graphics.pop()
	end
}
