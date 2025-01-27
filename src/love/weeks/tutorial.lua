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

weekData[1] = {
	init = function(songNum)
		bpm = 100
		
		enemyFrameTimer = 0
		boyfriendFrameTimer = 0
		
		sounds = {
			["miss"] = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			["death"] = love.audio.newSource("sounds/death.ogg", "static")
		}
		
		sheets = {
			["icons"] = love.graphics.newImage(graphics.imagePath("icons")),
			["notes"] = love.graphics.newImage(graphics.imagePath("notes"))
		}
		
		sprites = {
			["icons"] = love.filesystem.load("sprites/icons.lua")
		}
		
		stageBack = Image(love.graphics.newImage(graphics.imagePath("week1/stage-back")))
		stageFront = Image(love.graphics.newImage(graphics.imagePath("week1/stage-front")))
		curtains = Image(love.graphics.newImage(graphics.imagePath("week1/curtains")))
		
		stageFront.y = 400
		curtains.y = -100
		
		enemy = love.filesystem.load("sprites/girlfriend.lua")()
		boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
		
		enemy.x, enemy.y = 30, -90
		boyfriend.x, boyfriend.y = 260, 100
		
		enemyIcon = sprites["icons"]()
		boyfriendIcon = sprites["icons"]()
		
		enemyIcon.y = 350
		enemyIcon.sizeX, enemyIcon.sizeY = 1.5, 1.5
		boyfriendIcon.y = 350
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.5, 1.5
		
		enemyIcon:animate("girlfriend", false)
		
		weekData[1].load()
	end,
	
	load = function()
		weeks.load()
		
		inst = nil
		voices = love.audio.newSource("music/tutorial/tutorial.ogg", "stream")
		
		weekData[1].initUI(songNum)
		
		weeks.voicesPlay()
	end,
	
	initUI = function(songNum)
		weeks.initUI()
		
		weeks.generateNotes(love.filesystem.load("charts/tutorial/tutorial" .. songAppend .. ".lua")())
	end,
	
	update = function(dt)
		if gameOver then
			if not graphics.isFading then
				if input:pressed("confirm") then
					if inst then -- In case "confirm" is pressed before game over music starts
						inst:stop()
					end
					inst = love.audio.newSource("music/game-over-end.ogg", "stream")
					inst:play()
					
					Timer.clear()
					
					cam.x, cam.y = -boyfriend.x, -boyfriend.y
					
					boyfriend:animate("dead confirm", false)
					
					graphics.fadeOut(3, weekData[1].load)
				elseif input:pressed("gameBack") then
					graphics.fadeOut(1, weekData[1].stop)
				end
			end
			
			boyfriend:update(dt)
			
			return
		end
			
		oldMusicThres = musicThres
		
		musicTime = musicTime + (love.timer.getTime() * 1000) - previousFrameTime
		previousFrameTime = love.timer.getTime() * 1000
		
		if voices:tell("seconds") * 1000 ~= lastReportedPlaytime then
			musicTime = (musicTime + (voices:tell("seconds") * 1000)) / 2
			lastReportedPlaytime = voices:tell("seconds") * 1000
		end
		
		musicThres = math.floor(musicTime / 100) -- Since "musicTime" isn't precise, this is needed
		musicPos = musicTime * 0.6 * speed
		
		for i = 1, #events do
			if events[i].eventTime <= musicTime then
				if events[i].bpm then
					bpm = events[i].bpm
					
					enemy.anim.speed = 14.4 / (60 / bpm)
				end
				
				if camTimer then
					Timer.cancel(camTimer)
				end
				if events[i].mustHitSection then
					camTimer = Timer.tween(1.5, cam, {x = -boyfriend.x + 50, y = -boyfriend.y + 50}, "out-quad")
				else
					camTimer = Timer.tween(1.5, cam, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
				end
				
				table.remove(events, i)
				
				break
			end
		end
		
		if musicThres ~= oldMusicThres and math.fmod(musicTime, 240000 / bpm) < 100 then
			Timer.tween((60 / bpm) / 16, cam, {sizeX = camScale.x * 1.05, sizeY = camScale.y * 1.05}, "out-quad", function() Timer.tween((60 / bpm), cam, {sizeX = camScale.x, sizeY = camScale.y}, "out-quad") end)
		end
		
		enemy:update(dt)
		boyfriend:update(dt)
		
		if enemyFrameTimer >= 29 then
			enemy:animate("idle", true)
			enemy.anim.speed = 14.4 / (60 / bpm)
			
			enemyFrameTimer = 0
		end
		enemyFrameTimer = enemyFrameTimer + 14.4 / (60 / bpm) * dt
		
		if boyfriendFrameTimer >= 13 then
			boyfriend:animate("idle", true)
			boyfriendFrameTimer = 0
		end
		boyfriendFrameTimer = boyfriendFrameTimer + 24 * dt
		
		if not graphics.isFading and not voices:isPlaying() then
			storyMode = false
			
			graphics.fadeOut(1, weekData[1].stop)
		end
		
		weeks.updateUI(dt)
	end,
	
	draw = function()
		weeks.draw()
		
		if not inGame or gameOver then return end
		
		love.graphics.push()
			love.graphics.scale(cam.sizeX, cam.sizeY)
			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)
				
				stageBack:draw()
				stageFront:draw()
				enemy:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)
				
				boyfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 1.1, cam.y * 1.1)
				
				curtains:draw()
			love.graphics.pop()
		love.graphics.pop()
		
		love.graphics.push()
			love.graphics.scale(uiScale.x, uiScale.y)
			
			weeks.drawUI()
		love.graphics.pop()
	end,
	
	stop = function()
		stageBack = nil
		stageFront = nil
		curtains = nil
		
		weeks.stop()
	end
}
