-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local system = require( "system" )

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local uiGroup
local mapBtn = {}
local playBtn

local function loadData()
 
    local filePath = system.pathForFile( "data/data.json" , system.ResourceDirectory )
 
	local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
		io.close( file )
		--dataTable = json.decode( contents )
        local decoded, pos, msg = json.decodeFile( filePath )
        maps = decoded['maps']
		
    end
end


-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease(event)
    
    local obj = event.target

    -- go to level1.lua scene
    for i= 1, table.maxn( mapBtn ), 1 do
        display.remove(mapBtn[i])
    end

	composer.removeScene('scenes.maps')
	composer.gotoScene( "scenes.levels", { effect = "fade", time = 500, params = { map = obj.name*1} })
	
	return true	-- indicates successful touch
end

local function onPlayBtn2Release()
    
    --display.remove(playBtn)
    --display.remove(playBtn2)
	
	-- go to level1.lua scene
	
	composer.removeScene('scenes.maps')
	composer.gotoScene( "menu" , { effect = "fade", time = 500})
	
	return true	-- indicates successful touch
end


function scene:create( event )
	local sceneGroup = self.view
	print("create")

    
    
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	audio.play(music, { channel=1, loops=-1 } )
    audio.setVolume( 0.75, { channel=1 } )
    
    loadData()
	-- display a background image
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	local background = display.newRect( display.screenOriginX, display.screenOriginY, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	background:setFillColor( 0, 0, 0, 1 )
	
	local titleCover = display.newRoundedRect( display.contentCenterX, 75, 300, 80,20 )
	titleCover:setFillColor( 1,1,1,0.2 )


    local titleLogo = display.newImageRect( "images/logos/maps2.png", 264, 60 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 75	

	-- create a widget button (which will loads level1.lua on release)
	
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( titleCover )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		print("show will")

		uiGroup = display.newGroup()    -- Display group for UI objects like the score
		sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

		playBtn2 = widget.newButton{
			label="back",
			labelColor = { default={0}, over={128} },
			shape = "circle",
			fillColor = { default={ 1, 0, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			radius=25,
			onRelease = onPlayBtn2Release	-- event listener function
		}
		playBtn2.x = 30
		playBtn2.y = display.contentHeight - 40
		playBtn2:insert( uiGroup )

		for index, value in next, maps do
        

				mapBtn[value.id*1] = widget.newButton{
				id = value.id,
				label = value.id,
				labelColor = { default={0}, over={128} },
				shape = "circle",
				fillColor = { default={ 0.6, 0, 0, 0.8 }, over={ 0.8, 0, 0, 0.8 } },
				strokeColor = { default={ 0, 0, 0, 0.9 }, over={ 0.4, 0.1, 0.2 } },
				strokeWidth = 1,
				radius = 25, 
				x = -180 + display.contentCenterX + value.id*1 * 60,
				y = 200,
				onRelease = onPlayBtnRelease	-- event listener function
				}
			mapBtn[value.id*1].name= value.id*1
			mapBtn[value.id*1]:insert( uiGroup )
			if(mapsTable[value.id*1] == 1) then
				mapBtn[value.id*1]:setFillColor( 0, 0.7, 0.1, 1)
			elseif(mapsTable[value.id*1] == 2) then
				mapBtn[value.id*1]:setFillColor(1, 1, 1, 1)
			elseif(mapsTable[value.id*1] == 0) then
				mapBtn[value.id*1]:setFillColor(0.6, 0, 0, 0.8)
			else
				mapBtn[value.id*1]:setFillColor(0.6, 0.6, 0.6, 0.8)
				mapBtn[value.id*1]:setEnabled(false) 
			end
		end

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		print("show did")
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
		print("hide will")
	elseif phase == "did" then
		-- Called when the scene is now off screen
		print("hide did")
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	for index, value in next, sceneGroup do
		print(index)
		print(value)
	end
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	print("destroy")
	--audio.stop()
	--music = nil
	--audio.dispose( music )
    playBtn2:removeSelf()
	--sceneGroup:removeSelf()
	for i = #mapBtn, 1, -1 do
		display.remove( mapBtn[i] )
		table.remove( mapBtn, i )
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