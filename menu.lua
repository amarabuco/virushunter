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
local playBtn
local playBtn2

mapsTable = {}
levelsTable = {}
scoresTable = {}
balanceTable = {}
userTable = {}
weaponsTable = {}
itemsTable = {}
dealsTable = {}

local function onComplete( event )
    if ( event.action == "clicked" ) then
        local i = event.index
        if ( i == 1 ) then
            -- Do nothing; dialog will simply dismiss
        elseif ( i == 2 ) then
            -- Open URL if "Learn More" (second button) was clicked
            system.openURL( "http://www.coronalabs.com" )
        end
    end
end

--local alert = native.showAlert( "Alert", "Turn silent/mute mode OFF to hear the sounds." , { "OK" } )

--[[

-- SHARE ---

local serviceName = "facebook"  -- Supported values are "twitter", "facebook", or "sinaWeibo"
 
local isAvailable = native.canShowPopup( "social", serviceName )

 
if ( isAvailable ) then
 
    local listener = {}
     
    function listener:popup( event )
        print( "name: " .. event.name )
        print( "type: " .. event.type )
        print( "action: " .. tostring( event.action ) )
        print( "limitReached: " .. tostring( event.limitReached ) )
    end
 
    native.showPopup( "social",
    {
        service = serviceName,
        message = "Hi there!",
        listener = listener,
        image = 
        {
            { filename="world.jpg", baseDir=system.ResourceDirectory },
            { filename="bkg_wood.png", baseDir=system.ResourceDirectory }
        },
        url = 
        {
            "http://www.coronalabs.com",
            "http://docs.coronalabs.com"
        }
    })
 
else
 
    native.showAlert(
        "Cannot send " .. serviceName .. " message.",
        "Please setup your " .. serviceName .. " account or check your network connection.",
        { "OK" } )
end


-- POP UP IOS ---

local activity = require( "CoronaProvider.native.popup.activity" )
native.showPopup( "activity", {"bacana"} )
]]--

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.maps", { effect = "fade", time = 500, params = { level = "1"} })
	
	return true	-- indicates successful touch
end

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease2()
	
	-- go to level1.lua scene
	audio.stop()
	--audio.dispose( music )
	music = nil
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function onPlayBtnRelease3()
	
	-- go to level1.lua scene
	system.openURL( 'https://coronahunter.app' )
	--composer.gotoScene( "scenes.scores", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function onMusicBtn()
	
	-- go to level1.lua scene
	audio.stop(1)
	--composer.gotoScene( "scenes.info", "fade", 500 )
	
	return true	-- indicates successful touch
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
        store = decoded['store']
        weapons = decoded['weapons']
        items = decoded['items']
	end	
end

local function loadUser()

	local db = {"maps","levels","scores","balance","user","weapons","items","deals"}

	for i=1 , #db, 1 do 

		local filePath = system.pathForFile( db[i] .. ".json", system.DocumentsDirectory )
	
		local file = io.open( filePath, "r" )
		
		if file then
			local contents = file:read( "*a" )
			io.close( file )
			local data = json.decode( contents )
			entries = table.maxn(data)
			if (i == 1) then
				mapsTable = data
			elseif(i == 2) then
				levelsTable = data
			elseif(i == 3) then
				scoresTable = data
			elseif(i == 4) then
				balanceTable = data
			elseif(i == 5) then
				userTable = data
			elseif(i == 6) then
				weaponsTable = data
			elseif(i == 7) then
				itemsTable = data
			elseif(i == 8) then
				dealsTable = data
			end
		end

		if ( entries == nil or entries == 0 or file == nil ) then
			if (i == 1) then
				table.insert(mapsTable,0)
				for i= 2,table.maxn( maps ), 1 do
					table.insert(mapsTable,-1)
				end
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( mapsTable ) )
					io.close( file )
				end
			elseif(i == 2) then
				table.insert(levelsTable,0)
				for i= 2,table.maxn( levels ), 1 do
					table.insert(levelsTable,-1)
				end
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( levelsTable ) )
					io.close( file )
				end
			elseif(i == 3) then
				scoresTable = {}
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( scoresTable ) )
					io.close( file )
				end
			elseif(i == 4) then
				table.insert(balanceTable,0)
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( balanceTable ) )
					io.close( file )
				end
			elseif(i == 5) then
				table.insert(userTable,{life = 10})
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( userTable ) )
					io.close( file )
				end
			elseif(i == 6) then
				for i= 1,table.maxn( weapons ), 1 do
					table.insert(weaponsTable, {weapon = i, qtd = 0})
				end
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( weaponsTable ) )
					io.close( file )
				end
			elseif(i == 7) then
				for i= 1,table.maxn( items ), 1 do
					table.insert(itemsTable, {item = i, qtd = 0})
				end
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( itemsTable ) )
					io.close( file )
				end
			elseif(i == 8) then
				dealsTable = {}
				local file = io.open( filePath, "w" )
				if file then
					file:write( json.encode( dealsTable ) )
					io.close( file )
				end
			end
		end
	end
end

function scene:create( event )
	local sceneGroup = self.view
	loadData()
	loadUser()
	--[[
	print('MAPS')
	for i=1, #mapsTable, 1 do
		print(i .. ': ' .. mapsTable[i])
	end
	]]--
	
	--[[
	print("LEVELS")
	for i=1, #levelsTable, 1 do
		print(i .. ': ' .. levelsTable[i] )
	end
	
	
	print("SCORES")
	for i=1, #scoresTable, 1 do
		for index, value in next, scoresTable[i] do
			print(index .. ': ' .. value )
		end
	end
	]]--

	print("USER")
	print(userTable[1].life)

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	--local music = audio.loadStream( "sounds/drums.wav")
	audio.reserveChannels( 1 )
	local music = audio.loadStream( "sounds/NightRunner.mp3")
	--local music = audio.loadStream( "sounds/Horror13.mp3")
	audio.play(music, { channel=1, loops=-1 } )
	audio.setVolume( 0.75, { channel=1 } )
	-- display a background image
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	local background = display.newRect( display.screenOriginX, display.screenOriginY, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	background:setFillColor( 0, 0, 0, 1 )

	-- corona sprite
	local sheetOptions = {
		width = 64,
		height = 64,
		numFrames = 2
	}
	
	local corona1 = display.newImageRect( "coronabgk.png", 80 , 80 )
	corona1.alpha = 0
	corona1.x = math.random( 25, 75 )
	corona1.y = math.random( 100, 250 )

	local corona2 = display.newImage( "coronabgk.png", 50 , 50 )
	corona2.alpha = 0
	corona2.x = math.random( 75, 200 )
	corona2.y = math.random( 100, 250 )

	local corona3 = display.newImage( "coronabgk.png", 50 , 50 )
	corona3.alpha = 0
	corona3.x = display.contentCenterX + math.random( 75, 150 )
	corona3.y = math.random( 150, 250 )

	local corona4 = display.newImageRect( "coronabgk.png", 80 , 80 )
	corona4.alpha = 0
	corona4.x = display.contentCenterX + math.random( 150, 200 )
	corona4.y = math.random( 100, 250 )

	local function repeticao() 
		corona1.alpha = 0
		corona1.x = math.random( 25, 75 )
		corona1.y = math.random( 50, 250 )
		transition.fadeIn( corona1, { time=3000} )
		corona2.alpha = 0
		corona2.x = math.random( 75, 200 )
		corona2.y = math.random( 150, 250 )
		transition.fadeIn( corona2, { time=3000} )
		corona3.alpha = 0
		corona3.x = display.contentCenterX + math.random( 75, 150 )
		corona3.y = math.random( 150, 250 )
		transition.fadeIn( corona3, { time=3000} )
		corona4.alpha = 0
		corona4.x = display.contentCenterX + math.random( 150, 200 )
		corona4.y = math.random( 100, 250 )
		transition.fadeIn( corona4, { time=3000} )
	end
	
	--corona.alpha = 0
	--transition.blink( corona, { time = 3000 } )
	--transition.blink( corona, { onStart= start, onRepeat= repeticao, delay=5000 } )
	--timer.performWithDelay(0,transition.blink( corona, { time=2000 } ), -1)
	timer.performWithDelay(2000,repeticao, -1)
	
	--transition.fadeOut( corona, { time=2000 }  )
	
	--[[
	local spriteSheet = graphics.newImageSheet( "coronabgk.png", sheetOptions )
	-- sequences table
	local spriteSequence = {
		{
			name = "blink",
			start = 1,
			count = 2,
			time = 200,
			loopCount = 0,
			loopDirection = "bounce"
		}
	}

	local newSprite = display.newSprite( spriteSheet, spriteSequence )

	newSprite.x = 50
	newSprite.y = 50
	--newSprite:play()
	]]--

	-- create/position logo/title image on upper-half of the screen
	local titleCover = display.newRoundedRect( display.contentCenterX, 60, 300, 100,20 )
	titleCover:setFillColor( 1,1,1,0.2)


	local titleLogo = display.newImageRect( "logo3.png", 264, 96 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 60

	local versionText = display.newText( "Stay Home, Stay Safe! ", display.contentCenterX, display.contentCenterY-display.contentHeight*0.11, native.systemFont, 14 )

	
	--[[ 
	-- sprite
	local sheetOptions = {
		width = 512,
		height = 256,
		numFrames = 8
	}
	local sheet_runningCat = graphics.newImageSheet( "images/sprites-cat-running.png", sheetOptions )
	-- sequences table
	local sequences_runningCat = {
		{
			name = "normalRun",
			start = 1,
			count = 8,
			time = 800,
			loopCount = 0,
			loopDirection = "forward"
		}
	}

	local runningCat = display.newSprite( sheet_runningCat, sequences_runningCat )
	runningCat.x= display.contentCenterX
	runningCat.y=display.contentCenterY
	runningCat:play()
	]]--

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Play Now",
		
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0, 1, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
		strokeColor = { default={ 0, 0, 0, 0.9 }, over={ 0.4, 0.1, 0.2 } },
		strokeWidth = 1,
		cornerRadius = 10,
		--default="button.png",
		--over="button-over.png",
		width=display.contentWidth*0.4, height=display.contentHeight*0.15,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	

	-- create a widget button (which will loads level1.lua on release)
	playBtn2 = widget.newButton{
		label="Survivor",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 1, 0, 0, 0.8}, over={ 0, 0.2, 1, 1 } },
		strokeColor = { default={ 0, 0, 0, 0.9 }, over={ 0.4, 0.1, 0.2 } },
		strokeWidth = 1,
		cornerRadius = 10,
		--default="button.png",
		--over="button-over.png",
		width=display.contentWidth*0.4, height=display.contentHeight*0.15,
		onRelease = onPlayBtnRelease2	-- event listener function
	}

	-- create a widget button (which will loads level1.lua on release)
	
	playBtn3 = widget.newButton{
		label="Info",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0.5, 0.5, 1, 0.8 }, over={ 0, 0.2, 1, 1 } },
		strokeColor = { default={ 0, 0, 0, 0.9 }, over={ 0.4, 0.1, 0.2 } },
		strokeWidth = 1,
		cornerRadius = 10,
		--default="button.png",
		--over="button-over.png",
		width=display.contentWidth*0.4, height=display.contentHeight*0.15,
		onRelease = onPlayBtnRelease3	-- event listener function
		--onRelease = facebookListener	-- event listener function
	}
	musicBtn = widget.newButton{
		label="stop",
		labelColor = { default={0}, over={128} },
		shape = "circle",
		fillColor = { default={ 0.5, 0.5, 0.5, 0.8 }, over={ 0, 0.2, 1, 1 } },
		--default="button.png",
		--over="button-over.png",
		--width=40, height=40,
		radius=25,
		onRelease = onMusicBtn	-- event listener function
	}

	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - display.contentHeight*0.50
	
	playBtn2.x = display.contentCenterX
	playBtn2.y = display.contentHeight - display.contentHeight*0.3255

	playBtn3.x = display.contentCenterX
	playBtn3.y = display.contentHeight - display.contentHeight*0.16

	musicBtn.x = 30
	musicBtn.y = 20
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( playBtn2 )
	sceneGroup:insert( playBtn3 )
	sceneGroup:insert( musicBtn )
	sceneGroup:insert( titleCover )
	sceneGroup:insert( corona1 )
	sceneGroup:insert( corona2 )
	sceneGroup:insert( corona3 )
	sceneGroup:insert( corona4 )
	sceneGroup:insert( versionText )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		audio.play(music, { channel=1, loops=-1 } )
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

		--local alert = native.showAlert( "No Deal", "Not enought money.", { "OK", "Learn More" }, onComplete )
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
	audio.stop()
	music = nil
	audio.dispose( music )

	if playBtn2 then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
		playBtn2:removeSelf()	-- widgets must be manually removed
		playBtn2 = nil
		playBtn3:removeSelf()	-- widgets must be manually removed
		playBtn3 = nil
		musicBtn:removeSelf()	-- widgets must be manually removed
		musicBtn = nil

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