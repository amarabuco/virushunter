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

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local scrollView

-- forward declarations and other locals
local background
local playBtn
local mapBtn = {}
local level

local function scrollListener( event )
 
    local phase = event.phase
    if ( phase == "began" ) then print( "Scroll view was touched" )
    elseif ( phase == "moved" ) then print( "Scroll view was moved" )
    elseif ( phase == "ended" ) then print( "Scroll view was released" )
    end
 
    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
 
    return true
end

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
		
    end
end


-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
    
    
    -- go to level1.lua scene
    composer.removeScene('scenes.prelevel')

    if (level < 11) then
        composer.gotoScene( "game", { effect = "crossFade", time = 500, params = { map = map, level = tostring(level)} })
    elseif (level > 20) then
        composer.gotoScene( "scenes.maps", { effect = "crossFade", time = 500 })
    else
        composer.gotoScene( "scenes.store", { effect = "crossFade", time = 500, params = { map = map, level = tostring(level)} })
    end
  
	
	return true	-- indicates successful touch
end

local function onPlayBtn2Release()
    
    -- go to level1.lua scene
    composer.removeScene('scenes.prelevel')
	composer.gotoScene( "scenes.levels", { effect = "fade", time = 500, params = { map = map} })
	
	return true	-- indicates successful touch
end

local function toMenu()
    
        composer.removeScene('prelevel')
        composer.gotoScene( "menu")
	
	return true	-- indicates successful touch
end

function scene:create( event )
    local sceneGroup = self.view
    
    map = event.params.map*1
    level = event.params.level*1
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	local music = audio.loadStream( "sounds/drums.wav")
	--audio.play(music, { channel=1, loops=-1 } )
    audio.setVolume( 0.75, { channel=1 } )
    
    --print("images/intro/" .. level ..".jpg")

    loadData()
	-- display a background image
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
    
end

function scene:show( event )
	local sceneGroup = self.view
    local phase = event.phase
    
    

	if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen

        local uiGroup = display.newGroup()    -- Display group for UI objects like the score
        sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

        loadData()
        for index, value in next, event.params do
            print(index .. tostring(value))
        end

        map = event.params.map*1
        if event.params.level ~= nil then
            level = event.params.level*1
        else
            toMenu()
        end

        scrollView = widget.newScrollView(
        {
            --top = 0,
            --left = 0,
            width = display.actualContentWidth+400, 
            --width = 500, 
            --height = 400,
            scrollWidth = display.actualContentWidth+400,
            scrollHeight = screenH,
            listener = scrollListener,
            backgroundColor = { 0 }
        }
    )

    local filePath = system.pathForFile( "images/intro/" .. level ..".jpeg" , system.ResourceDirectory )
    print(filePath)

    if (filePath ~= nil) then
        background = display.newImageRect( "images/intro/" .. level ..".jpeg", display.contentWidth , display.contentHeight )
        --background = display.newImage("images/intro/" .. level ..".jpeg" )
        background.anchorX = 0 
        background.anchorY = 0
        background.x = 0


    else
        background = display.newImageRect( "images/intro/0.jpeg", display.actualContentWidth , display.actualContentHeight )
        --background = display.newImage("images/intro/0.jpeg" )
        background.anchorX = 0 
        background.anchorY = 0
        background.x = -30
        
    end
 

    playBtn = widget.newButton{
		label="go",
		labelColor = { default={0}, over={128} },
		shape = "circle",
		fillColor = { default={ 0, 1, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		radius=25,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.actualContentWidth - 100
    playBtn.y = display.contentHeight - 40
    
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

	-- create a widget button (which will loads level1.lua on release)
    local descricao
    local titleCover
	


    descricao = display.newText( tostring(level) .. ". " .. tostring(levels[level*1].name), display.contentCenterX, 15, native.systemFont, 22 )
    descricao:setFillColor(1,1,1,1)
    titleCover = display.newRect( display.contentCenterX+6, 0, display.actualContentWidth, 60,20 )
    titleCover:setFillColor( 1,1,1,0.2 )
    
    --

	
	-- all display objects must be inserted into group
    --sceneGroup:insert( background )
    scrollView:insert( background )
    if descricao then
        scrollView:insert( descricao )
    end
    if titleCover then
        scrollView:insert( titleCover )
    end

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
    print('destroy')
    
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc.
    display.remove(playBtn)
    display.remove(playBtn2)
    display.remove(blackground)
    display.remove(background)
    scrollView:removeSelf()
	--audio.stop()
	--music = nil
    --audio.dispose( music )
    
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene