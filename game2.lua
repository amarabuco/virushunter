-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local system = require( "system" )
composer.isDebug = true

-- include Corona's "physics" library
local physics = require "physics"
local widget = require "widget"

-- Initialize variables
local lifeTotal = userTable[1].life
local lives = userTable[1].life
local score = 0
local damage = 0
local died = false
local lifeBar = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY, display.actualContentWidth,  30  )
lifeBar.anchorX = 0
lifeBar.anchorY = 1
lifeBar:setFillColor(1,0,0,1)

-- game controls
local pause = false

-- targets
local asteroidsTable = {}
local gameTable = {}
local waveTable = {}
local waveLoopTimer
local gameLoopTimer

-- Items
local shield = 1

-- Weapons
local sword
local swordTotal = 10
local swordImg
local swordLoad = 0

-- UI
local livesText
local scoreText

-- Sounds
local shotSound
local hurtSound
audio.reserveChannels( 2 )

audio.setVolume( 0.4 )

-- SceneGroups
local backGroup
local mainGroup
local uiGroup
--------------------------------------------

-- Functions
local function loadData()
 
	local filePath = system.pathForFile( "data/data.json" , system.ResourceDirectory )

	local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
		io.close( file )
		--dataTable = json.decode( contents )
        local decoded, pos, msg = json.decodeFile( filePath )
        maps = decoded['maps']
        levels = decoded['levels']
        gameplay = decoded['gameplay']
        typeTarget = decoded['type']
    	targets = decoded['targets']
        sounds = decoded['sounds']
		backgrounds = decoded['backgrounds']
		
		
		for index, value in next, gameplay do
			--print (index)
			--print (value.level)
			if value.level == level then
				table.insert( waveTable, value )
				--table.insert( gameTable, value )
			end
		end
		
		--print('size: ')
		--print(table.maxn( waveTable ))
		--interactions = table.maxn( gameTable )
		waves = waveTable[table.maxn( waveTable )].time*1

    end
end

local function saveScores()

	scoresItem = { id = os.date('%Y%m%d%H%M%S'), map = map ,level = level , score = score , damage = damage , life = lives, date = os.date('%Y-%m-%d %H:%M:%S')}
	table.insert(scoresTable,scoresItem)
	balanceTable[1] = balanceTable[1]*1 + scoresItem.score*1

	local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
	end

	local filePath = system.pathForFile( "balance.json", system.DocumentsDirectory )

    local file = io.open( filePath, "w" )
	if file then
        file:write( json.encode( balanceTable ) )
        io.close( file )
    end
end

local function saveLevel()

	if(damage == 0) then
		levelsTable[level*1] = 2
	else
		levelsTable[level*1] = 1
	end
		
	if(levelsTable[level*1+1] == - 1) then
		levelsTable[level*1+1] = 0
	end
	
	for i=1, #levelsTable, 1 do
		--print(i .. ': ' .. levelsTable[i] )
	end

	local filePath = system.pathForFile( "levels.json", system.DocumentsDirectory )
	print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( levelsTable ) )
        io.close( file )
    end
end

local function saveMap()
 
	if( level % 10 == 0 and level == 10) then
		mapsTable[level] = 1
	end
 
	local filePath = system.pathForFile( "maps.json", system.DocumentsDirectory )

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( mapsTable ) )
        io.close( file )
    end
end

local function onReplayBtnRelease()
	
	-- go to level1.lua scene
	--scene:destroy (event)
	if(loseBtn) then
		loseBtn:removeSelf()	-- widgets must be manually removed
		loseBtn = nil
		menuBtn:removeSelf()	-- widgets must be manually removed
		menuBtn = nil
	end
	if(winBtn) then
		winBtn:removeSelf()	-- widgets must be manually removed
		winBtn = nil
		nextBtn:removeSelf()	-- widgets must be manually removed
		nextBtn = nil
	end
	replayBtn:removeSelf()	-- widgets must be manually removed
	replayBtn = nil

	composer.removeScene("game")
	composer.gotoScene( "game", { effect = "fade", time = 1000, params = { map = map, level = tostring(level)} })
	
end

local function onMenuBtnRelease()

	-- go to level1.lua scene
	--scene:destroy (event)
	composer.removeScene('game')
	if(loseBtn) then
		loseBtn:removeSelf()	-- widgets must be manually removed
		loseBtn = nil
	end
	if(winBtn) then
		winBtn:removeSelf()	-- widgets must be manually removed
		winBtn = nil
	end
	replayBtn:removeSelf()	-- widgets must be manually removed
	replayBtn = nil
	menuBtn:removeSelf()	-- widgets must be manually removed
	menuBtn = nil

	composer.removeScene('game')
	composer.gotoScene( "menu", "fade", 500 )
end

local function onNextBtnRelease()

	-- go to level1.lua scene
	--scene:destroy (event)
	composer.removeScene('game')
	if(loseBtn) then
		loseBtn:removeSelf()	-- widgets must be manually removed
		loseBtn = nil
	end
	if(winBtn) then
		winBtn:removeSelf()	-- widgets must be manually removed
		winBtn = nil
	end
	nextBtn:removeSelf()	-- widgets must be manually removed
	nextBtn = nil

	composer.removeScene('game')
	composer.gotoScene( "game", { effect = "fade", time = 1000, params = { map = map, level = tostring(level+1)} })
end

local function onResumeRelease()

    physics.start()
    timer.resume(gameLoopTimer)
    timer.resume(waveLoopTimer)
	audio.resume()
	pause = false
    
    resumeBtn:removeSelf()	-- widgets must be manually removed
	resumeBtn = nil
    pausedText:removeSelf()	-- widgets must be manually removed
	pausedText = nil
	menuBtn:removeSelf()	-- widgets must be manually removed
	menuBtn = nil

    
end



local function onPauseRelease()

	if (pause == false ) then
		--- PROBLEMA: QUANDO PAUSA KILL AINDA FUNCIONA
		physics.pause()
		timer.pause(waveLoopTimer)
		timer.pause(gameLoopTimer)
		audio.pause()
		pause = true 
		
		--  draw the body at the very bottom of the screen
		
		pausedText = display.newText( "Paused ", display.contentCenterX, display.contentCenterY-50, native.systemFont, 28 )

		resumeBtn = widget.newButton{
			label="Resume",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 1, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=100, y=20,
			onRelease = onResumeRelease	-- event listener function
		}
		resumeBtn.x = display.contentCenterX-75
		resumeBtn.y = display.contentCenterY

		menuBtn = widget.newButton{
			label="menu",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 1, 1, 0.8 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=100, y=20,
			onRelease = onMenuBtnRelease	-- event listener function
		}
		menuBtn.x = display.contentCenterX+75
		menuBtn.y = display.contentCenterY
	end
	
end



local function updateText()
	livesText.text = "Life: " .. lives
	scoreText.text = "Score: " .. score
end


-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local function stopShield()
	shield = 1
	if shieldBody then
		shieldBody:removeSelf()
	end
end

local function weaponLoad()
	if swordLoad == 0 then
		print('on')
		swordLoad = 1
	else
		print('off')
		swordLoad = 0
	end
	swordActive:setFillColor(1,1,1, 0.5 - 0.5 * swordLoad)
end

local function kill( event )

	print('kill')
	print(physics)
	if ( event.phase == "began" and pause == false ) then

		local obj = event.target
		obj:setFillColor( 1,1,1, (1 - 1/(obj.life*1)) )
		obj.life = obj.life - 1
		if obj.life == 0 then
			if( targets[obj.id*1].type*1 == 2 ) then
				audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
				print('life change kill')
				lives = lives - targets[obj.id*1].damage*1
			elseif( targets[obj.id*1].type*1 == 3 ) then
					if (shield == 0) then
						stopShield()
					end
					audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
					shield = 0 
					shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-30, display.actualContentWidth,  30  )
					shieldBody.anchorX = 0
					shieldBody.anchorY = 1
					shieldBody:setFillColor(0,0,1,0.8)
					timer.performWithDelay(3000,stopShield, 1)
			elseif( targets[obj.id*1].type*1 == 4 ) then
					audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
					shield = 2
					shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-15, display.actualContentWidth,  15  )
					shieldBody.anchorX = 0
					shieldBody.anchorY = 1
					shieldBody:setFillColor(0,0,0,0.9)
					timer.performWithDelay(3000,stopShield, 1)
			else
				audio.play( shotSound )
			end
			display.remove( obj )
		end

		if ( lives < 0.2 * lifeTotal ) then
			local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
			audio.play(heartbeat, { channel=2, loops=-1 })
		else
			audio.pause(2)
		end

		score = score + obj.score
		scoreText.text = "Score: " .. score
		livesText.text = "Life: " .. lives
		lifeBar.width = display.actualContentWidth * lives/lifeTotal
	end

	if ( event.phase == "moved" and pause == false ) then

		if (swordLoad == 1 and sword > 0) then
			sword = sword - 1

			local obj = event.target
			obj.life = obj.life - 1
			if obj.life == 0 then
				if( targets[obj.id*1].type*1 == 2 ) then
					audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
					print('life change kill 2')
					print(lives)
					print(targets[obj.id*1].damage*1)
					lives = lives - targets[obj.id*1].damage*1
				elseif( targets[obj.id*1].type*1 == 3 ) then
						audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
						shield = 0 
						shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-30, display.actualContentWidth,  30  )
						shieldBody.anchorX = 0
						shieldBody.anchorY = 1
						shieldBody:setFillColor(0,0,1,0.8)
						timer.performWithDelay(5000,stopShield, 1)
				elseif( targets[obj.id*1].type*1 == 4 ) then
						audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
						shield = 2
						shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-15, display.actualContentWidth,  15  )
						shieldBody.anchorX = 0
						shieldBody.anchorY = 1
						shieldBody:setFillColor(0,0,0,0.9)
						timer.performWithDelay(3000,stopShield, 1)
				else
					audio.play( swordSound )
				end
				display.remove( obj )
			end

			if ( lives < 0.2 * lifeTotal ) then
				local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
				audio.play(heartbeat, { channel=2, loops=-1 })
			else
				audio.pause(2)
			end

			score = score + obj.score
			scoreText.text = "Score: " .. score
			livesText.text = "Life: " .. lives
			local swordBar = display.newRect( 0, 0, 0,  45  )
			swordBar:setFillColor(0,0,0)
			swordBar.x=0
			swordBar.y = 20
			swordBar.anchorX = 1
			swordBar.width = 45 * (1 - sword/swordTotal)
			--local swidth = swordImg.width
			--swordImg.width = swidth * sword/swordTotal
			lifeBar.width = display.actualContentWidth * lives/lifeTotal
		end
	end
end

local function createAsteroid()

	--print('target')
	--print(targets[gameplay[level*1].item*1].image)
	--print(targets[gameplay[level*1].item*1].width)
	--local newAsteroid = display.newImageRect( mainGroup, "images/targets/corona.png", 45, 45 )
	local newAsteroid = display.newImageRect( mainGroup, "images/targets/" .. targets[gameTable[1].item*1].image, (targets[gameTable[1].item*1].width)*1, (targets[gameTable[1].item*1].height)*1 )
	newAsteroid:addEventListener( "touch", kill )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=targets[gameTable[1].item*1].radius*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	if targets[gameTable[1].item*1].type*1 == 1 then
		newAsteroid.myName = "virus"
	else
		newAsteroid.myName = "others"
	end
	newAsteroid.id = targets[gameTable[1].item*1].id
	newAsteroid.life = targets[gameTable[1].item*1].life
	newAsteroid.score = targets[gameTable[1].item*1].score

	--print(gameTable[1].x*1)
	newAsteroid.x = gameTable[1].x*1
	--print(gameTable[1].y*1)
	newAsteroid.y = gameTable[1].y*1
	newAsteroid:setLinearVelocity( gameTable[1].vx*1, gameTable[1].vy*1)
	

	newAsteroid:applyTorque(gameTable[1].torque*1)
	--print(newAsteroid)
	
end

local function createSprite()

	local sheetOptions = {
		width = 64,
		height = 64,
		numFrames = 2
	}
	local spriteSheet = graphics.newImageSheet( "images/targets/" .. targets[gameTable[1].item*1].image, sheetOptions )
	-- sequences table
	local spriteSequence = {
		{
			name = "blink",
			start = 1,
			count = 2,
			time = 1000,
			loopCount = 0,
			loopDirection = "bounce"
		}
	}

	local newSprite = display.newSprite( mainGroup, spriteSheet, spriteSequence )
	

	newSprite:addEventListener( "touch", kill )
	table.insert( asteroidsTable, newSprite )
	physics.addBody( newSprite, "dynamic", { radius=targets[gameTable[1].item*1].radius*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	if targets[gameTable[1].item*1].type*1 == 1 then
		newSprite.myName = "virus"
	else
		newSprite.myName = "others"
	end
	newSprite.id = targets[gameTable[1].item*1].id
	newSprite.life = targets[gameTable[1].item*1].life
	newSprite.score = targets[gameTable[1].item*1].score

	--print(gameTable[1].x*1)
	newSprite.x = gameTable[1].x*1
	--print(gameTable[1].y*1)
	newSprite.y = gameTable[1].y*1
	newSprite:play()
	newSprite:setLinearVelocity( gameTable[1].vx*1, gameTable[1].vy*1 )
	

	newSprite:applyTorque(gameTable[1].torque*1)
end

local function gameLoop()
	
	
	-- Create new virus
	print('Time : ' .. gameTable[1].time)
	print('Item : ' .. gameTable[1].item)
	print('lives : ' .. tostring(lives))
	print(physics)

	if(gameTable[1].item ~= "-1") then
		if(targets[gameTable[1].item*1].sprite*1 == 1 ) then
			createSprite()
		else
			createAsteroid()
		end
	end
	table.remove( gameTable, 1)
	
	--print(table.maxn(waveTable))
	--print(table.maxn(waveTable) == 0 and table.maxn(gameTable) == 0)

	if (table.maxn(waveTable) == 0 and table.maxn(gameTable) == 0 ) then
		pauseBtn:removeSelf()
		timer.performWithDelay(5000,win, 1)
	end

	-- Remove asteroids which have drifted off screen
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]
		
		--print(i)
		--print(thisAsteroid.x)
		if (  thisAsteroid.x == nil or (thisAsteroid.x < -100) or
			(thisAsteroid.x > display.contentWidth + 100) or
			 (thisAsteroid.y < -100) or
			(thisAsteroid.y > display.contentHeight + 100) )
		then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )
		end
		
	end
	
end

function win()
	
	
	if damage == 0 then
		audio.play(audio.loadSound( "sounds/" .. '237351__xtrgamr__parentsclapandcheer-02.wav' ))
		perfectText = display.newText( uiGroup, "PERFECT !!!", display.contentCenterX, display.contentCenterY+75, native.systemFont, 36 )
    end
	if lives > 0 then
		pause = true
		timer.pause(gameLoopTimer)
		timer.cancel(gameLoopTimer)
		print('win')
		print('physics stop')
		physics.pause()
		--physics.stop()
		audio.pause(2)
		
		--display.remove( body )
		
		winBtn = widget.newButton{
			label="Win",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 0.6, 0, 0.8 }, over={ 0, 0.8, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=300, y=20,
			--onRelease = onPlayBtnRelease	-- event listener function
		}
		winBtn.x = display.contentCenterX
		winBtn.y = display.contentCenterY - 75
		replayBtn = widget.newButton{
			label="try again",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 1, 0, 1 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=100, y=20,
			onRelease = onReplayBtnRelease	-- event listener function
		}
		replayBtn.x = display.contentCenterX-75
		replayBtn.y = display.contentCenterY
		nextBtn = widget.newButton{
			label="next",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 1, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=100, y=20,
			onRelease = onNextBtnRelease	-- event listener function
		}
		nextBtn.x = display.contentCenterX+75
		nextBtn.y = display.contentCenterY
		
		composer.setVariable( "finalScore", score )
		saveLevel()
		saveScores()
		
	else
		timer.performWithDelay(0,endgame, 1)
	end
end

local function waveLoop()

	gameTable = {}

	local function compare( a, b )
		return a.time*1 > b.time*1  -- Note ">" as the operator
	end
	 
	table.sort(waveTable,compare)

	local gameTime = waveTable[table.maxn(waveTable)].time*1
	--[[
	for i=#waveTable, 1 , -1 do
		print(waveTable[i].time)
	end
	]]--
	

	for i=#waveTable, 1 , -1 do
		--print(index .. ' : ' .. value.time)
		if waveTable[i].time*1 == gameTime*1 then
			table.insert( gameTable, waveTable[i])
			table.remove( waveTable)
			--print('removeu: ' .. value.time*1)
		else
			break
		end
	end
	
	gameLoopTimer = timer.performWithDelay( 0, gameLoop, table.maxn(gameTable) )
	--print(table.maxn(gameWave))

end

local function endGame()
	audio.pause(hearbeat)
	print('dead')
	print('physics stop')
	physics.pause()
	--physics.stop()
	timer.cancel(waveLoopTimer)
	timer.cancel(gameLoopTimer)
	loseBtn = widget.newButton{
		label="Lose",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 1, 0, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=300, y=20,
		--onRelease = onPlayBtnRelease	-- event listener function
	}
	loseBtn.x = display.contentCenterX
	loseBtn.y = display.contentCenterY - 75
	replayBtn = widget.newButton{
		label="try again",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0, 1, 0, 1 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=100, y=20,
		onRelease = onReplayBtnRelease	-- event listener function
	}
	replayBtn.x = display.contentCenterX-75
	replayBtn.y = display.contentCenterY
	menuBtn = widget.newButton{
		label="menu",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0, 1, 1, 0.8 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=100, y=20,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn.x = display.contentCenterX+75
	menuBtn.y = display.contentCenterY
	
end


local function onCollision( event )

	print('lives: ' .. tostring(lives))
	print('collision')
	print('physics: ' .. tostring(physics))
	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "virus" and obj2.myName == "virus" ) or
			 ( obj1.myName == "virus" and obj2.myName == "virus" ) )
		then
			-- Remove both the laser and virus
			--local vx1, vy1 = obj1:getLinearVelocity()
			--local vx2, vy2  = obj2:getLinearVelocity()
			--print(vx2)
			--print(vy2)
			--obj1:setLinearVelocity( -vx1 * math.random(1,2) , -vy1 * math.random(1,2) )
			--obj2:setLinearVelocity( -vx2 * math.random(1,2) , -vy2 * math.random(1,2) )
			--display.remove( obj1 )
			--display.remove( obj2 )

			--[[
			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end
			]]--

		elseif ( ( obj1.myName == "body" and obj2.myName == "virus" ) or
				 ( obj1.myName == "virus" and obj2.myName == "body" ) )
		then
			
			damage = damage + 1
			if(obj1.myName == "virus")
			then
				audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj1.id*1].sound*1].file )  )
				display.remove( obj1 )
				objimpact = obj1
				--obj1:setLinearVelocity( 0 , 0 )
			end
			if(obj2.myName == "virus")
			then
				audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj2.id*1].sound*1].file )  )
				display.remove( obj2 )
				objimpact = obj2
				--obj2:setLinearVelocity( 0 ,0 )
			end

			if ( died == false ) then
				-- Update lives
				if( targets[objimpact.id*1].damage*1 > 0 ) then
					print('life change collision 0')
					print(lives)
					print(targets[objimpact.id*1].damage*1*shield)
					lives = lives - targets[objimpact.id*1].damage*1*shield
				end
				livesText.text = "Life: " .. lives
				lifeBar.width = display.actualContentWidth * lives/lifeTotal
				if ( lives < 0.2 * lifeTotal ) then
					local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
					audio.play(heartbeat, { channel=2, loops=-1 })
				else
					audio.pause(2)
				end
				if ( lives < 1 ) then
					pause = true
					print('dead trigger')
					print(physics)
					timer.pause(waveLoopTimer)
					timer.pause(gameLoopTimer)
					--display.remove( body )
					timer.performWithDelay(0,endGame )
				end
			end
		
		elseif ( ( obj1.myName == "body" and obj2.myName == "others" ) or
				 ( obj1.myName == "others" and obj2.myName == "body" ) )
		then
			
			if(obj1.myName == "others")
			then
				display.remove( obj1 )
				--obj1:setLinearVelocity( 0 , 0 )
			end
			if(obj2.myName == "others")
			then
				display.remove( obj2 )
				--obj2:setLinearVelocity( 0 ,0 )
			end
		else
			print('colisão irrelevante')
		end
	end
end

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
    sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
    
    level = event.params.level
    loadData()
    
	--touch and collision listeners
	--Runtime:addEventListener( "collision", onCollision )

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	--[[
	for index, value in next, levels[1] do
		print(index .. ": " .. value)
	end
	]]--
	physics.setGravity(levels[level*1].gx*1,levels[level*1].gy*1 )
	--physics.setDrawMode('hybrid') 
	physics.pause()

	-- sounds
	--local shotSound = audio.loadSound( "sounds/33276__mastafx__shot.wav" )
	shotSound = audio.loadSound( "sounds/149177__deathnsorrow__shot-and-reload.wav" )
	--swordSound = audio.loadSound( "sounds/209081__lukesharples__blade-slice8.wav" )
	swordSound = audio.loadSound( "sounds/109420__black-snow__sword-slice-11.wav" )
	--shotSound = audio.loadSound( "sounds/33276__mastafx__shot.wav" )
	hurtSound = audio.loadSound( "sounds/342229__christopherderp__hurt-1-male.wav" )
	
	map = event.params.map*1
    level = event.params.level*1

	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	--local background = display.newImageRect(backGroup, "images/backgrounds/hemacias.jpg", screenW, screenH )
	local background = display.newImageRect(backGroup, "images/backgrounds/" .. backgrounds[levels[level*1].image*1].name, screenW-75, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .9 )

	-- create a body object and add physics (with custom shape)
	local body = display.newRect( mainGroup ,display.screenOriginX, display.screenOriginY, display.actualContentWidth-30,  30  )
	body:setFillColor(black)
	body.anchorX = 0
	body.anchorY = 1
	--  draw the body at the very bottom of the screen
	body.x, body.y = display.screenOriginX+30, display.actualContentHeight + display.screenOriginY
	body.myName = "body"
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	physics.addBody( body, "static", { friction=0.3 } )

	-- Display lives and score
	local stats = display.newRoundedRect( mainGroup ,display.screenOriginX+50, display.screenOriginY+5, 160,  30, 5  )
	stats:setFillColor(1,1,1,0.75)
	stats.anchorX = 0
	stats.anchorY = 0

	pauseBtn = widget.newButton{
		label=" || ",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0.5, 0.5, 0.5, 0.8 }, over={ 0, 0.2, 1, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=40, height=40,
		onRelease = onPauseRelease	-- event listener function
	}
	pauseBtn.anchorX = 1
	pauseBtn.anchorY = 0
	pauseBtn.x=display.actualContentWidth-50
	pauseBtn.y = 0

	livesText = display.newText( uiGroup, "Life: " .. lives, 50, 20, native.systemFont, 18 )
	livesText:setFillColor(0,0,0)
	scoreText = display.newText( uiGroup, "Score: " .. score, 120, 20, native.systemFont, 18 )
	scoreText:setFillColor(0,0,0)
	
	local on = 0
	if(swordTotal > 0) then
		swordImg = display.newImageRect( mainGroup , "images/weapons/sword.png", 40, 40)
		--swordText = display.newText( uiGroup, sword, display.screenOriginX+10, display.screenOriginY+10, native.systemFont, 20  )
		swordImg.x=-22
		swordImg.y = 22
		swordImg.alfa = 0.2
		sword = 30
		swordImg:addEventListener( "tap", weaponLoad )

		swordActive =  display.newRect( mainGroup , 50, 50, 50,  45  )
		swordActive:setFillColor(1,1,1, 0.5)
		swordActive.x=0
		swordActive.y = 20
		swordActive.anchorX = 1
	end 

	
    
	-- all display objects must be inserted into group
	display.setStatusBar( display.HiddenStatusBar )
	
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		lifeTotal = userTable[1].life
		lives = userTable[1].life
		score = 0
		damage = 0
		died = false
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		print('lives: ' .. tostring(lives))
		print('collision')
		print('physics: ' .. tostring(physics))

		--print(asteroidsTable)
		Runtime:addEventListener( "collision", onCollision )
		
        waveLoopTimer = timer.performWithDelay( 1000, waveLoop, waves )
		--gameLoopTimer = timer.performWithDelay( levels[level*1].delay*1, gameLoop, interactions )
		
	end

end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		print('scene hide')
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()

	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	--local sceneGroup = self.view
	print('destroy')
	--package.loaded[physics] = nil
	--physics = nil
	--composer.removeScene( "game" )
	timer.cancel(waveLoopTimer)
	timer.cancel(gameLoopTimer)

	--audio.dispose( shotSound )
    --audio.dispose( hurtSound )
	
end

--crate:addEventListener( "touch", kill )
---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene
