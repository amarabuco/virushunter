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
local playBtn2
local mapBtn = {}

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
local function onPlayBtnRelease(event)
    
    local obj = event.target

    
    --print(obj.name)
	-- go to level1.lua scene
    composer.removeScene('scenes.levels')
    if obj.name ~= nil then
        print('level: ' .. tostring(obj.name))
	    composer.gotoScene( "scenes.prelevel", { effect = "fade", time = 500, params = { map = map, level = tostring(obj.name)} })
    else
        print(obj)
    end
        
    return true	-- indicates successful touch
end

local function onPlayBtn2Release()
	
	-- go to level1.lua scene
    composer.removeScene('scenes.levels')
	composer.gotoScene( "scenes.maps" , { effect = "crossFade", time = 500})
	
	return true	-- indicates successful touch
end


function scene:create( event )
    local sceneGroup = self.view
    --print("create")
    --print(mapBtn)

    -- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	--audio.play(music, { channel=1, loops=-1 } )
    --audio.setVolume( 0.75, { channel=1 } )
    
    map = event.params.map*1

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

    local titleLogo = display.newImageRect( "images/logos/levels.png", 264, 60 )
	titleLogo.x = display.contentCenterX
    titleLogo.y = 75	

    --local description = display.newText( maps[map].description, display.contentCenterX, display.contentCenterY-50, native.systemFont, 20 )
    --description:setFillColor(1,1,1,1)

    

    --print(levels)

	-- create a widget button (which will loads level1.lua on release)
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	--sceneGroup:insert( description )
	sceneGroup:insert( titleCover )
	


end

function scene:show( event )
	local sceneGroup = self.view
    local phase = event.phase
	
	if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
        print("show will")
        --print(mapBtn)        
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

        for index, value in next, levels do
            --print(index)
            --print(value)
            if(value.map*1 == map and value.id*1 % 2 ~= 0 ) then
                local position
                if (value.id*1 > 10) then
                    position = value.id*1 - (value.map*1 - 1) * 10
                else
                    position = value.id*1
                end
                mapBtn[value.id*1] = widget.newButton{
                label=value.id,
                labelColor = { default={0}, over={128} },
                shape = "roundedRect",
                fillColor = { default={ 0, 0.6, 0, 0.8 }, over={ 0, 0.8, 0.2, 1 } },
                width = 50, 
                x = -150 + display.contentCenterX + position * 30,
                y = 200,
                onRelease = onPlayBtnRelease	-- event listener function
                }
  
                mapBtn[value.id*1].name = value.id*1
                if(levelsTable[value.id*1] == 1) then
                    mapBtn[value.id*1]:setFillColor( 0, 0.7, 0.1, 1)
                elseif(levelsTable[value.id*1] == 2) then
                    mapBtn[value.id*1]:setFillColor(1, 1, 1, 1)
                elseif(levelsTable[value.id*1] == 0) then
                    mapBtn[value.id*1]:setFillColor(0.6, 0, 0, 0.8)
                else
                    mapBtn[value.id*1]:setFillColor(0.6, 0.6, 0.6, 0.8)
                    mapBtn[value.id*1]:setEnabled(false)
                end
                
           
            elseif(value.map*1 == map and value.id*1 % 2 == 0) then
                local position
                if (value.id*1 > 10) then
                    position = value.id*1 - (value.map*1 - 1) * 10
                else
                    position = value.id*1
                end
                mapBtn[value.id*1] = widget.newButton{
                    label=value.id,
                    labelColor = { default={0}, over={128} },
                    shape = "roundedRect",
                    fillColor = { default={ 0, 0.6, 0, 0.8 }, over={ 0, 0.8, 0.2, 1 } },
                    width = 50, 
                    x = -180 + display.contentCenterX + position * 30,
                    y = 260,
                    --isEnabled = false
                    onRelease = onPlayBtnRelease	-- event listener function
                }
                 
                mapBtn[value.id*1].name = value.id*1
                if(levelsTable[value.id*1] == 1) then
                    mapBtn[value.id*1]:setFillColor( 0, 0.7, 0.1, 1)
                elseif(levelsTable[value.id*1] == 2) then
                    mapBtn[value.id*1]:setFillColor(1, 1, 1, 1)
                elseif(levelsTable[value.id*1] == 0) then
                    mapBtn[value.id*1]:setFillColor(0.6, 0, 0, 0.8)
                else
                    mapBtn[value.id*1]:setFillColor(0.6, 0.6, 0.6, 0.8)
                    mapBtn[value.id*1]:setEnabled(false) 
                end
                
                --mapBtn[value.id*1].name= value.id*1
                --mapBtn[value.id*1]:insert( uiGroup )            
            end
            
        end
    sceneGroup:insert( playBtn2 )

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc.
        print("show did")
        --print(mapBtn)

        
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
    print("destroy")
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	--audio.stop()
	--music = nil
    --audio.dispose( music )
    display.remove(playBtn)
    display.remove(playBtn2)

    local len = table.maxn(mapBtn) 
    for i = len, len - 10, -1 do
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