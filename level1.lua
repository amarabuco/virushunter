-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local system = require( "system" )

-- include Corona's "physics" library
local physics = require "physics"
local widget = require "widget"

-- Initialize variables
local lifeTotal = 30
local lives = 30
local score = 0
local died = false
local lifeBar = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY, display.actualContentWidth,  30  )
lifeBar.anchorX = 0
lifeBar.anchorY = 1
lifeBar:setFillColor(1,0,0,1)

local virusTable = {}
local asteroidsTable = {}
local gameLoopTimer

local livesText
local scoreText
local scoresTable = {}
local filePath = system.pathForFile( "data/score.json" )
local path = system.pathForFile( nil, system.DocumentsDirectory )
--print( path )

local shotSound
local hurtSound

local backGroup
local mainGroup
local uiGroup
--------------------------------------------
local function onReplayBtnRelease()
	
	-- go to level1.lua scene
	--scene:destroy
	composer.removeScene('level1')
	composer.gotoScene( "level1", "fade", 500 )

end

local function onMenuBtnRelease()

	-- go to level1.lua scene
	--scene:destroy
	composer.removeScene('level1')
	loseBtn:removeSelf()	-- widgets must be manually removed
	loseBtn = nil
	replayBtn:removeSelf()	-- widgets must be manually removed
	replayBtn = nil
	menuBtn:removeSelf()	-- widgets must be manually removed
	menuBtn = nil
	composer.gotoScene( "menu", "fade", 500 )
end


local function updateText()
	livesText.text = "Life: " .. lives
	scoreText.text = "Score: " .. score
end

local function loadScores()
 
	local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local function kill( event )
	


	if ( event.phase == "began" ) then

		audio.play( shotSound )

		local obj = event.target
		print(obj)
		display.remove( obj )
		score = score + 1
		scoreText.text = "Score: " .. score
		
	end
end

local function createAsteroid()

	local newAsteroid = display.newImageRect( mainGroup, "images/targets/1.png", 45, 45 )
	newAsteroid:addEventListener( "touch", kill )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=20, bounce=0.8 } )
	newAsteroid.myName = "virus"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		newAsteroid.x = -60
		newAsteroid.y = math.random( display.contentHeight/2,display.contentHeight )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( display.contentHeight/2,display.contentHeight )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	newAsteroid:applyTorque( math.random( 1,6 ) )
	--print(newAsteroid)
	
end


local function gameLoop()

	-- Create new virus
	createAsteroid()
	

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


local function endGame()
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
	
	composer.setVariable( "finalScore", score )
	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
    composer.setVariable( "finalScore", 0 )
	--print (filepath)
	--saveScores()
	--composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end


local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "virus" and obj2.myName == "virus" ) or
			 ( obj1.myName == "virus" and obj2.myName == "virus" ) )
		then
			-- Remove both the laser and virus
			local vx1, vy1 = obj1:getLinearVelocity()
			local vx2, vy2  = obj2:getLinearVelocity()
			--print(vx2)
			--print(vy2)
			obj1:setLinearVelocity( -vx1 * math.random(1,2) , -vy1 * math.random(1,2) )
			obj2:setLinearVelocity( -vx2 * math.random(1,2) , -vy2 * math.random(1,2) )
			--display.remove( obj1 )
			--display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

		elseif ( ( obj1.myName == "body" and obj2.myName == "virus" ) or
				 ( obj1.myName == "virus" and obj2.myName == "body" ) )
		then
			
			audio.play( hurtSound )

			if(obj1.myName == "virus")
			then
				display.remove( obj1 )
				--obj1:setLinearVelocity( 0 , 0 )
			end
			if(obj2.myName == "virus")
			then
				display.remove( obj2 )
				--obj2:setLinearVelocity( 0 ,0 )
			end

			if ( died == false ) then
				-- Update lives
				lives = lives - 1
				livesText.text = "Life: " .. lives
				lifeBar.width = display.actualContentWidth * lives/lifeTotal
				
				if ( lives == 0 ) then
					timer.cancel(gameLoopTimer)
					physics.pause()
					--display.remove( body )
					timer.performWithDelay(0,endGame )
				end
			end
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
	
	--touch and collision listeners
	--Runtime:addEventListener( "collision", onCollision )

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setGravity( 0, 0 )
	--physics.setDrawMode('hybrid') 
	physics.pause()

	loadScores()
	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
	for i = 1, 10 do
        if ( scoresTable[i] ) then
			--print (scoresTable[i])
		end
	end

	-- sounds
	--local shotSound = audio.loadSound( "sounds/33276__mastafx__shot.wav" )
	shotSound = audio.loadSound( "sounds/149177__deathnsorrow__shot-and-reload.wav" )
	--shotSound = audio.loadSound( "sounds/33276__mastafx__shot.wav" )
	hurtSound = audio.loadSound( "sounds/342229__christopherderp__hurt-1-male.wav" )

	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newImageRect(backGroup, "images/backgrounds/hemacias.jpg", screenW, screenH )
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
	livesText = display.newText( uiGroup, "Life: " .. lives, 50, 20, native.systemFont, 20 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 150, 20, native.systemFont, 20 )
	
	-- all display objects must be inserted into group
	display.setStatusBar( display.HiddenStatusBar )
	
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()

		--print(asteroidsTable)
		Runtime:addEventListener( "collision", onCollision )
		
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		
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
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "game" )
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil

	--audio.dispose( shotSound )
    --audio.dispose( hurtSound )
	
end


if ((menuBtn) or (replayBtn)) then
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
