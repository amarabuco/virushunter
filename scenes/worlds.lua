-----------------------------------------------------------------------------------------
--
-- worlds.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.levels", "fade", 500 )
	
	return true	-- indicates successful touch
end

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease2()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.levels", "fade", 500 )
	
	return true	-- indicates successful touch
end
local function onPlayBtnRelease3()
	
	-- go to level1.lua scene
	composer.gotoScene( "menu", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	local background = display.newRect( display.screenOriginX, display.screenOriginY, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- create/position logo/title image on upper-half of the screen
    local titleLogo = display.newText( "Worlds", 100, 200, native.systemFont, 16 )
    titleLogo.x = display.contentCenterX
	titleLogo.y = 50
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Black Plague",
		labelColor = { default={255}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0, 0, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125

	-- create a widget button (which will loads level1.lua on release)
	playBtn2 = widget.newButton{
		label="Pandemy",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0.5, 1, 0, 1 }, over={ 0, 0.2, 1, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease2	-- event listener function
    }
    playBtn3 = widget.newButton{
		label="Back",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 1, 0.5, 0, 1 }, over={ 0, 0.2, 1, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease3	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125

	playBtn2.x = display.contentCenterX
    playBtn2.y = display.contentHeight - 75
    
    playBtn3.x = display.contentCenterX
	playBtn3.y = display.contentHeight - 25
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( playBtn2 )
	sceneGroup:insert( playBtn3 )
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
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
        playBtn = nil
        playBtn2:removeSelf()	-- widgets must be manually removed
        playBtn2 = nil
        playBtn3:removeSelf()	-- widgets must be manually removed
		playBtn3 = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene