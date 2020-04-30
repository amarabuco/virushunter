-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local system = require( "system" )
local math = require( "math" )
composer.isDebug = true


-- include Corona's "physics" library
local physics = require "physics"
local widget = require "widget"
local wp = require( "lib.weapons" )
local it = require( "lib.items" )
local tg = require( "lib.targets" )
local act = require( "lib.actions" )

-- Initialize variables
local lifeTotal
local lives
local score
local headCount = 0
local headTotal = 0
local damage
local died
local win

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
local inventoryGame
local weapons
local items
local selectImg
local sword = 0
local swordTotal = 0
local swordImg
local swordLoad = 0
local itemImg
local itemUnits = 0
local itemSelected
local weaponSelected
local weaponsRows 
local itemsRows
local wActive = 0
local iActive = 0
local onUnloadItem
local onUnloadWeapon
local weaponLoad
local swordText
local itemText

-- UI
local livesText
local scoreText
local targetsText

-- Sounds
local shotSound
local hurtSound
audio.reserveChannels( 2 )
audio.reserveChannels( 4 )

audio.setVolume( 1 )

-- SceneGroups
local backGroup
local mainGroup
local uiGroup
--------------------------------------------

local function printMemUsage()
	local memUsed = (collectgarbage("count"))/1000

	local textUsed = system.getInfo("textureMemoryUsed")/1000000

	print("\n--- MEMORY USAGE ----")
	print("SYSTEM MEM:", string.format("%.03f", memUsed), "Mb")
	print("Texture MEM:", string.format("%.03f", textUsed), "Mb")
	print("\n--- MEMORY USAGE ----")

	return true
end


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
        sounds = decoded['sounds']
        music = decoded['music']
        weapons = decoded['weapons']
		items = decoded['items']
		
		weaponsRows = table.maxn( weapons )
        itemsRows = table.maxn( items )
		
		for index, value in next, gameplay do
			--print (index)
			--print (value.level)
			if value.level == level then
				table.insert( waveTable, value )
				if (value.item*1 < 11 and value.item*1 > 0) then
					headTotal = headTotal + 1
				end
			end
		end
		
		--print('size: ')
		--print(table.maxn( waveTable ))
		--interactions = table.maxn( gameTable )
		waves = waveTable[table.maxn( waveTable )].time*1

    end
end

local function onUnloadWeapon()

	display.remove(swordImg)
	display.remove(swordText)
	sword = 0
	swordTotal = 0
	wActive = 0
	
end

local function onUnloadItem()

	itemImg:removeEventListener( "touch", use)
	display.remove(itemImg)
	display.remove(itemText)
	itemUnits = 0
	iActive = 0

end


local function selectWeapon()

	return weaponsTable[id].qtd
end

local function selectItem()
	return weaponsTable[id].qtd
end

local function loadWeapon(event)
	local obj = event.target
	local id = obj.id*1

	if(wActive == 1) then
		onUnloadWeapon()
	end

	sword = weaponsTable[id].qtd
	swordTotal = weaponsTable[id].qtd

	--swordImg = display.newImageRect( mainGroup , "images/weapons/sword2x.png", 45 , 45)
	swordImg = display.newImageRect( mainGroup, "images/weapons/" .. weapons[id].image, 45, 45 )
	swordText = display.newText( uiGroup, sword, display.actualContentWidth-25, display.screenOriginY+175, native.systemFont, 20  )
	swordImg.x= display.actualContentWidth-25
	swordImg.y = 125
	event.target.alpha = 0.3
	--
	--swordImg:addEventListener( "tap", multiTouch )

	--[[
	
	swordActive =  display.newRect( mainGroup , 50, 50, 50,  45  )
	swordActive:setFillColor(1,1,1, 0.5)
	swordActive.x= display.actualContentWidth-25
	swordActive.y = 125
	swordActive.alfa = 0.2
	]]--

	audio.play( audio.loadSound( "sounds/load.wav" )  )
	--weaponLoad()
	if swordLoad == 0 then
		print('on')
		swordLoad = 1
	else
		print('off')
		swordLoad = 0
	end

	wActive = 1
	
	--swordImg:addEventListener( "tap", weaponLoad )	

end

local function updateWeapon(id, qtd)
	weaponsTable[id].qtd = qtd

	local filePath = system.pathForFile( "weapons.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( weaponsTable ) )
        io.close( file )
    end
end

local function loadItem(event)
	local obj = event.target
	local id = obj.id*1

	if(iActive == 1) then
		onUnloadItem()
	end

	itemUnits = itemsTable[id].qtd

	--itemImg = display.newImageRect( mainGroup , "images/items/push.png", 45 , 45)
	itemImg = display.newImageRect( mainGroup, "images/items/" .. items[id].image, 45, 45 )
	itemText = display.newText( uiGroup, itemUnits, display.actualContentWidth-25, 275, native.systemFont, 20  )
	itemImg.x= display.actualContentWidth-25
	itemImg.y = 225
	event.target.alpha = 0.3
	itemImg.id = id
	--
	--itemImg:addEventListener( "touch", it.slow)
	audio.play( audio.loadSound( "sounds/387533__soundwarf__alert-short.wav" )  )

	itemImg:addEventListener( "tap", use )
	iActive = 1
end

local function updateItem(id, qtd)
	
	--print(itemsTable[id].qtd)
	itemsTable[id*1].qtd = qtd*1

	local filePath = system.pathForFile( "items.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( itemsTable ) )
        io.close( file )
    end
end


local function cleanLevel()

	for i = #asteroidsTable, 1, -1 do
		display.remove( asteroidsTable[i] )
		table.remove( asteroidsTable, i )
	end
	physics.removeBody(body)

	asteroidsTable = {}
	gameTable = {}
	waveTable = {}
end

local function loadMusic()
	audio.stop( 1 )
	audio.reserveChannels( 3 )
	--local soundTrack = audio.loadStream( "sounds/FightScene.mp3")
	--local soundTrack = audio.loadStream( "sounds/SearchAndDestroy.mp3")
	--local soundTrack = audio.loadStream( "music/Pentagram.mp3")
	local soundTrack = audio.loadStream( "music/" .. music[levels[level*1].music*1].file)
	
	audio.play(soundTrack, { channel=3, loops=-1 } )
	audio.setVolume( 0.3, { channel=3 } )
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
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( levelsTable ) )
        io.close( file )
    end
end

local function saveMap()
 
	if( level % 10 == 0) then
		print("level % 10 == 0")
		print(level % 10 == 0)
		mapsTable[map*1] = 1
		mapsTable[map*1+1] = 0
	end
 
	local filePath = system.pathForFile( "maps.json", system.DocumentsDirectory )

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( mapsTable ) )
        io.close( file )
    end
end

local function destroyButtons()
	--print(pause)
	if (lives < 1) then
		loseBtn:removeSelf()	-- widgets must be manually removed
		loseBtn = nil
		replayBtn:removeSelf()	-- widgets must be manually removed
		replayBtn = nil
	elseif(pause == true and win == 0) then
		resumeBtn:removeSelf()	-- widgets must be manually removed
		resumeBtn = nil
		pausedText:removeSelf()	-- widgets must be manually removed
		pausedText = nil
	elseif(win == 1 and level == 10 ) then
		return false
	elseif(win == 1) then
		winBtn:removeSelf()	-- widgets must be manually removed
		winBtn = nil
		replayBtn:removeSelf()	-- widgets must be manually removed
		replayBtn = nil
	end
		nextBtn:removeSelf()	-- widgets must be manually removed
		nextBtn = nil
		menuBtn:removeSelf()	-- widgets must be manually removed
		menuBtn = nil
end

local function onResumeRelease()
	
	print('resume')
	physics.start()
	if gameLoopTimer then
		timer.resume(gameLoopTimer)
	end
    timer.resume(waveLoopTimer)
	audio.resume()
	destroyButtons()
	pause = false
    
end

local function onReplayBtnRelease()
	
	-- go to level1.lua scene
	--scene:destroy (event)

	composer.removeScene("game")
	composer.gotoScene( "game", { effect = "crossFade", time = 1000, params = { map = map, level = tostring(level)} })
	
end

local function onMenuBtnRelease()

	-- go to level1.lua scene
	--scene:destroy (event)
	
	composer.removeScene("game")
	composer.gotoScene( "menu" , { effect = "zoomOutInFade", time = 1000})
end

local function onNextBtnRelease(event)

	-- go to level1.lua scene
	--scene:destroy (event)
	local obj = event.target

	composer.removeScene('game')
	if (obj.name == 'Next') then
		composer.gotoScene( "scenes.prelevel", { effect = "fade", time = 1000, params = { map = map, level = tostring(level+1)} })
	else
		composer.gotoScene( "scenes.levels", { effect = "fade", time = 1000, params = { map = map } })
	end
end

local function onClose(event)

	display.remove(inventoryGame)
	display.remove(closeBtn)
	display.remove(unloadBtn)
	onResumeRelease()

end



local function onUnload(event)

	onUnloadWeapon()
	onUnloadItem()
	audio.play( audio.loadSound( "sounds/387533__soundwarf__alert-short.wav" )  )

end


local function loadbuttons(win)
	local nextText = "Levels"
	if (win == 'w') then
		nextText = "Next"
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
		uiGroup:insert( winBtn )
	elseif (win == 'l') then
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
		uiGroup:insert( loseBtn )
	elseif (win == 'p') then
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
		uiGroup:insert( resumeBtn )
	end
	
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
	menuBtn.x = display.contentCenterX
	menuBtn.y = display.contentCenterY + 60
	uiGroup:insert( menuBtn )

	if (win ~= 'p') then
		replayBtn = widget.newButton{
			label="Try again",
			labelColor = { default={0}, over={128} },
			shape = "roundedRect",
			fillColor = { default={ 0, 1, 0, 1 }, over={ 0, 1, 0.2, 1 } },
			--default="button.png",
			--over="button-over.png",
			width=100, y=20,
			onRelease = onReplayBtnRelease	-- event listener function
		}
		replayBtn.x = display.contentCenterX-60
		replayBtn.y = display.contentCenterY
		uiGroup:insert( replayBtn )
	end

	nextBtn = widget.newButton{
		label= nextText,
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 0, 1, 0, 0.8 }, over={ 0, 1, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=100, y=20,
		onRelease = onNextBtnRelease	-- event listener function
	}
	nextBtn.x = display.contentCenterX+60
	nextBtn.y = display.contentCenterY
	nextBtn.name = nextText
	uiGroup:insert( nextBtn )

end


local function onPauseRelease()

	if (pause == false ) then
		
		physics.pause()
		timer.pause(waveLoopTimer)
		if gameLoopTimer then
			timer.pause(gameLoopTimer)
		end
		audio.pause()
		pause = true 
		
		--  draw the body at the very bottom of the screen
		
		pausedText = display.newText( "Paused ", display.contentCenterX, display.contentCenterY-50, native.systemFont, 28 )

		loadbuttons('p')
		
	end
	
end

local function loadUser()
	print('loadUser')
	lifeTotal = userTable[1].life
	lives = userTable[1].life
	score = 0
	headCount = 0
	damage = 0
	died = false
	win = 0
end

local function loadSword()
	--loadWeapon(1)
	if(level == 8 or level == 9) then
		sword = 20
		swordTotal = 20
		
		swordImg = display.newImageRect( mainGroup, "images/weapons/sword.png", 45, 45 )
		swordText = display.newText( uiGroup, sword, display.actualContentWidth-25, display.screenOriginY+175, native.systemFont, 20  )
		swordImg.x= display.actualContentWidth-25
		swordImg.y = 125

		weaponLoad()

	end

	if(level == 10) then
		sword = 100
		swordTotal = 100

		swordImg = display.newImageRect( mainGroup, "images/weapons/sword.png", 45, 45 )
		swordText = display.newText( uiGroup, sword, display.actualContentWidth-25, display.screenOriginY+175, native.systemFont, 20  )
		swordImg.x= display.actualContentWidth-25
		swordImg.y = 125

		weaponLoad()
	end
	
	--sword = loadWeapon(1)
	--swordTotal = loadWeapon(1)
end

local function loadfinal()
	audio.play(audio.loadSound( "sounds/" .. '237351__xtrgamr__parentsclapandcheer-02.wav' ))
	composer.removeScene("game")
	composer.gotoScene( "scenes.prelevel", { effect = "fade", time = 500, params = { map = map, level = 11} })
end


local function loadLevel()

end

local function updateText()
	livesText.text = "Life: " .. lives
	scoreText.text = "Score: " .. score
end


local function loadInventory()

	onPauseRelease()

	local function onRowRender2( event )
 
		-- Get reference to the row group
		local row = event.row
		local rowData = event.row.params
	 
		-- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
		local rowHeight = row.contentHeight
		local rowWidth = row.contentWidth
	 
		local id = display.newText( row, rowData.id, 0, 0, nil, 14 )
		local name = display.newText( row, rowData.name, 0, 0, nil, 14 )
		
		local image
		print(rowData.image)
		if (rowData.image == 'image') then
			image = display.newText( row, rowData.image, 0, 0, nil, 14 )
			image:setFillColor( 0 )
			image.anchorX = 0
			image.x = rowWidth * 0.5
			image.y = rowHeight * 0.5
			
		elseif (rowData.image ~= nil) then
			print(rowData.name)
			if(rowData.type*1 == 1) then
				image = display.newImageRect( row, "images/weapons/" .. rowData.image, 25, 25 )
			elseif(rowData.type*1 == 2) then
				image = display.newImageRect( row, "images/items/" .. rowData.image, 25, 25 )
			end
			image.anchorX = 0
			image.x = rowWidth * 0.5
			image.y = rowHeight * 0.5
			image.id = rowData.id

			if(rowData.type*1 == 1) then
				image:addEventListener('tap', loadWeapon)
			elseif(rowData.type*1 == 2) then
				image:addEventListener('tap', loadItem)
			end

			local shop = display.newImageRect( row, "images/icons/down.png", 20, 20 )
			shop.anchorX = 0
			shop.x = rowWidth * 0.4
			shop.y = rowHeight * 0.5
			shop.id = rowData.id
			if(rowData.type*1 == 1) then
				shop:addEventListener('tap', loadWeapon)
			elseif(rowData.type*1 == 2) then
				shop:addEventListener('tap', loadItem)
			end
		end
		local unit = display.newText( row, rowData.qtd, 0, 0, nil, 14 )

		
        
		
		id:setFillColor( 0 )
		name:setFillColor( 0 )
		unit:setFillColor( 0 )
	   
	 
		-- Align the label left and vertically centered
		id.anchorX = 0
		id.x = rowWidth * 0.05
		id.y = rowHeight * 0.5
	
		name.anchorX = 0
		name.x = rowWidth * 0.1
		name.y = rowHeight * 0.5
	   
		unit.anchorX = 0
		unit.x = rowWidth * 0.7
		unit.y = rowHeight * 0.5

	
	end

	inventoryGame = widget.newTableView(
        {
            top = 50,
            left = 0,
            width = display.actualContentWidth,
            --width = 500, 
            height = (weaponsRows * 20) + (itemsRows  * 15),
            onRowRender = onRowRender2,
            --onRowTouch = onRowTouch,
            listener = scrollListener
        }
    )

    local isCategoryHeader = true
    local rowHeightHeader = 36
    local rowColorHeader = { default={0.6,0.6,0.6}, over={1,0.5,0,0.2} }
    local lineColorHeader = { 0.5, 0.5, 0.5 }

    local isCategoryLineEven = false
    local rowHeightLineEven = 30
    local rowColorLineEven = { default={0.8,0.8,0.8,1}, over={1,0.5,0,0.2} }
    local lineColorLineEven = { 1, 1, 1 }
  
    local isCategoryLineOdd = false
    local rowHeightLineOdd = 30
    local rowColorLineOdd = { default={1,1,1,0.5}, over={1,0.5,0,0.2} }
    local lineColorLineOdd = { 1, 1, 1 }

    inventoryGame:insertRow(
        {
            isCategory = isCategoryHeader,
            rowHeight = rowHeightHeader,
            rowColor = rowColorHeader,
            lineColor = lineColorHeader,
            params = {
                id = "id",
                name = "name",
                image = "image",
                type = "type",
                qtd = "units"
            }
        }
    )

    inventoryGame:insertRow(
        {
            isCategory = false,
            rowHeight = 40,
            rowColor = { default={1,0,0,0.6}, over={1,0.5,0,0.2} },
            --lineColor =  { 1, 1, 1 },
            params = {
				id = "id",
				name = "WEAPONS",
                image = nil,
                type = "",
                qtd = ""
            }
        }
    )

    for index, item in next, weaponsTable do
        
        if (item.qtd == 0) then
            break
        end

        if (index % 2 == 0 ) then
            inventoryGame:insertRow{
            isCategory = isCategoryLineEven,
            rowHeight = rowHeightLineEven,
            rowColor = rowColorLineEven,
            lineColor = lineColorLineEven,  
            params = {
				id = item.weapon*1,
				name = weapons[item.weapon*1].name,
                image = weapons[item.weapon*1].image,
                type = 1,
                qtd = item.qtd
                }
            }
        else
            inventoryGame:insertRow{
                isCategory = isCategoryLineOdd,
                rowHeight = rowHeightLineOdd,
                rowColor = rowColorLineOdd,
                lineColor = lineColorLineOdd,  
                params = {
					id = item.weapon*1,
                    name = weapons[item.weapon*1].name,
                    image = weapons[item.weapon*1].image,
                    type = 1,
                    qtd = item.qtd
                    }
                }
            end
    end

    inventoryGame:insertRow(
        {
            isCategory = false,
            rowHeight = 40,
            rowColor = { default={0,0,1,0.5}, over={1,0.5,0,0.2} },
            --lineColor =  { 1, 1, 1 },
            params = {
                id = "",
                name = "ITEMS",
                image = nil,
                type = "",
                qtd = ""
            }
        }  
    )

    for index, item in next, itemsTable do
        
        if (item.qtd == 0) then
            break
        end

        if (index % 2 == 0 ) then
            inventoryGame:insertRow{
            isCategory = isCategoryLineEven,
            rowHeight = rowHeightLineEven,
            rowColor = rowColorLineEven,
            lineColor = lineColorLineEven,  
            params = {
				id = item.item*1,
                name = items[item.item*1].name,
                image = items[item.item*1].image,
                type = 2,
                qtd = item.qtd
                }
            }
        else
            inventoryGame:insertRow{
                isCategory = isCategoryLineOdd,
                rowHeight = rowHeightLineOdd,
                rowColor = rowColorLineOdd,
                lineColor = lineColorLineOdd,  
                params = {
					id = item.item*1,
                    name = items[item.item*1].name,
                    image = items[item.item*1].image,
                    type = 2,
                    qtd = item.qtd
                    }
                }
            end
	end

	closeBtn = widget.newButton{
		label="X",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 1, 0, 0, 1 }, over={ 0, 0.8, 0.2, 1 } },
		--default="button.png",
		--over="button-over.png",
		width=50, y=0,
		onRelease = onClose	-- event listener function
	}
	closeBtn.x = 25
	closeBtn.y = 25
	uiGroup:insert( closeBtn )

	unloadBtn = widget.newButton{
		label=" unload ",
		labelColor = { default={0}, over={128} },
		shape = "roundedRect",
		fillColor = { default={ 1, 1, 0, 1 }, over={ 1, 1, 0, 0.5 } },
		--default="button.png",
		--over="button-over.png",
		width=50, y=0,
		onRelease = onUnload	-- event listener function
	}
	unloadBtn.x = display.contentCenterX + 50
	unloadBtn.y = 25
	uiGroup:insert( unloadBtn )
	
end


-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local function stopShield()
	shield = 1
	if shieldBody then
		shieldBody:removeSelf()
	end
end

function weaponLoad()
	if swordLoad == 0 then
		print('on')
		swordLoad = 1
	else
		print('off')
		swordLoad = 0
	end
	--swordActive:setFillColor(1,1,1, 0.5 - 0.5 * swordLoad)
end

local function multiTouch()
	system.activate( "multitouch" )
end

function use (event)
	local obj = event.target
	local id =  obj.id*1

	if (itemsTable[id].qtd > 0) then
		

		local qtd = itemsTable[id].qtd
		qtd = qtd - 1
		updateItem(id,qtd)
		itemText.text = qtd
		
		if (id*1 < 4) then 
			if id*1 == 1 then
				lives = lives + 1
			elseif id*1 == 2 then
				lives = lives + 3
			elseif id*1 == 3 then
				lives = lives + 5
			end
			livesText.text = "Life: " .. lives
			
		elseif (id*1 == 4) then 
			
			if (shield == 0) then
				stopShield()
			end
			it.shield()
			timer.performWithDelay(2*levels[level*1].delay*1,stopShield, 1)
		elseif (id*1 == 5) then
			it.time = 5000
			it.gx = levels[level*1].gx*1
			it.gy = levels[level*1].gy*1	
			it.slow()
		elseif (id*1 == 6) then
			it.time = 4000
			it.gx = levels[level*1].gx*1
			it.gy = levels[level*1].gy*1	
			it.stop()
		end
		audio.play( audio.loadSound( "sounds/" .. sounds[items[id*1].sound*1].file )  )
	else
		display.remove(itemImg)
		display.remove(itemText)
	end
end

local function kill( event )

	--print('kill')
	--print(physics)
	if ( event.phase == "began" and pause == false ) then

		local obj = event.target
		
		obj:setFillColor( 1,1,1, (1 - 1/(obj.life*1)) )
		obj.life = obj.life - 1
		if obj.life == 0 then

			if( targets[obj.id*1].type*1 == 2 ) then
				audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
				--print('life change kill')
				lives = lives - targets[obj.id*1].damage*1
				damage = damage + 1
				if ( lives < 1 ) then
					pause = true
					--print('dead trigger')
					--print(physics)
					timer.pause(waveLoopTimer)
					timer.pause(gameLoopTimer)
					--display.remove( body )
					timer.performWithDelay(0,endGame )
				end
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
					timer.performWithDelay(2*levels[level*1].delay*1,stopShield, 1)
			elseif( targets[obj.id*1].type*1 == 4 ) then
					audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
					shield = 2
					shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-15, display.actualContentWidth,  15  )
					shieldBody.anchorX = 0
					shieldBody.anchorY = 1
					shieldBody:setFillColor(0,0,0,0.9)
					timer.performWithDelay(2*levels[level*1].delay*1,stopShield, 1)
			else
				audio.play( shotSound )
			end
			display.remove( obj )
			headCount = headCount + 1
		end

		if ( lives < 0.3 * lifeTotal ) then
			local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
			audio.play(heartbeat, { channel=10, loops=-1 })
			audio.setVolume( 2, { channel=10 } )
			audio.pause( 3)
		else
			audio.play(soundTrack,{ channel=3})
			audio.pause(10)
		end

		
		score = score + obj.score
		scoreText.text = "Score: " .. score
		livesText.text = "Life: " .. lives
		targetsText.text = tostring(headCount) .. "/".. tostring(headTotal)
		lifeBar.width = (display.actualContentWidth-50) * lives/lifeTotal
	end

	if ( event.phase == "moved" and pause == false ) then

		if (swordLoad == 1 and sword > 0) then
			sword = sword - 1
			updateWeapon(1,sword)
			print(sword)

			local obj = event.target
			print(obj.life)
			obj.life = obj.life - 1
			print(obj.life)
			if obj.life == 0 then
				
				if( targets[obj.id*1].type*1 == 2 ) then
					audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
					--print('life change kill 2')
					--print(lives)
					--print(targets[obj.id*1].damage*1)
					lives = lives - targets[obj.id*1].damage*1
					damage = damage + 1
					if ( lives < 1 ) then
						pause = true
						--print('dead trigger')
						--print(physics)
						timer.pause(waveLoopTimer)
						timer.pause(gameLoopTimer)
						--display.remove( body )
						timer.performWithDelay(0,endGame )
					end
				elseif( targets[obj.id*1].type*1 == 3 ) then
						audio.play( audio.loadSound( "sounds/" .. sounds[targets[obj.id*1].sound*1].file )  )
						shield = 0 
						shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-30, display.actualContentWidth,  30  )
						shieldBody.anchorX = 0
						shieldBody.anchorY = 1
						shieldBody:setFillColor(0,0,1,0.8)
						timer.performWithDelay(4000,stopShield, 1)
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
				headCount = headCount + 1
			end

			if ( lives < 0.3 * lifeTotal ) then
				local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
				audio.play(heartbeat, { channel=10, loops=-1 })
				audio.setVolume( 2, { channel=10 } )
				audio.pause( 3)
			else
				audio.pause(10)
				audio.play(soundTrack, { channel=3})
			end

			score = score + obj.score
			swordText.text = sword
			scoreText.text = "Score: " .. score
			livesText.text = "Life: " .. lives
			lifeBar.width = (display.actualContentWidth-50) * lives/lifeTotal
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
	if (targets[gameTable[1].item*1].radius*1 > 0) then
		physics.addBody( newAsteroid, "dynamic", { radius=targets[gameTable[1].item*1].radius*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	else
		physics.addBody( newAsteroid, "dynamic", { x=0, y=0, halfWidth=targets[gameTable[1].item*1].width*1, halfHeight=targets[gameTable[1].item*1].height*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	end

	if targets[gameTable[1].item*1].type*1 == 1 then
		newAsteroid.myName = "virus"
	else
		newAsteroid.myName = "others"
	end
	newAsteroid.id = targets[gameTable[1].item*1].id
	newAsteroid.life = targets[gameTable[1].item*1].life
	newAsteroid.score = targets[gameTable[1].item*1].score

	--print(gameTable[1].x*1)
	--newAsteroid.x = gameTable[1].x*1
	newAsteroid.x = gameTable[1].x*1 + display.contentCenterX
	--print(gameTable[1].y*1)
	--newAsteroid.y = gameTable[1].y*1
	newAsteroid.y = gameTable[1].y*1 + display.contentCenterY	
	newAsteroid:setLinearVelocity( gameTable[1].vx*1, gameTable[1].vy*1)
	

	newAsteroid:applyTorque(gameTable[1].torque*1)
	--print(newAsteroid)
	
end

local function cloneAsteroid(id,x,y)

	--print('target')
	--print(targets[gameplay[level*1].item*1].image)
	--print(targets[gameplay[level*1].item*1].width)
	--local newAsteroid = display.newImageRect( mainGroup, "images/targets/corona.png", 45, 45 )
	local newAsteroid = display.newImageRect( mainGroup, "images/targets/" .. targets[id].image, (targets[id].width)*1, (targets[id].height)*1 )
	newAsteroid:addEventListener( "touch", kill )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=targets[id].radius*1, bounce=targets[id].bounce*1 } )
	if targets[id].type*1 == 1 then
		newAsteroid.myName = "virus"
	else
		newAsteroid.myName = "others"
	end
	newAsteroid.id = targets[id].id
	newAsteroid.life = targets[id].life
	newAsteroid.score = targets[id].score

	--print(gameTable[1].x*1)
	--newAsteroid.x = gameTable[1].x*1
	newAsteroid.x = x
	--print(gameTable[1].y*1)
	--newAsteroid.y = gameTable[1].y*1
	newAsteroid.y = y	
	--newAsteroid:setLinearVelocity( vx, vy)
	

	--newAsteroid:applyTorque(0)
	--print(newAsteroid)
	
end

local function createSprite()

	local sheetOptions = {
		width = targets[gameTable[1].item*1].width,
		height = targets[gameTable[1].item*1].height*1,
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
	if (targets[gameTable[1].item*1].radius*1 > 0) then
		physics.addBody( newSprite, "dynamic", { radius=targets[gameTable[1].item*1].radius*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	else
		physics.addBody( newSprite, "dynamic", { x=0, y=0, halfWidth=targets[gameTable[1].item*1].width*1, halfHeight=targets[gameTable[1].item*1].height*1, bounce=targets[gameTable[1].item*1].bounce*1 } )
	end
	if targets[gameTable[1].item*1].type*1 == 1 then
		newSprite.myName = "virus"
	else
		newSprite.myName = "others"
	end
	newSprite.id = targets[gameTable[1].item*1].id
	newSprite.life = targets[gameTable[1].item*1].life
	newSprite.score = targets[gameTable[1].item*1].score

	--print(gameTable[1].x*1)
	--newSprite.x = gameTable[1].x*1
	newSprite.x = gameTable[1].x*1 + display.contentCenterX
	--print(gameTable[1].y*1)
	--newSprite.y = gameTable[1].y*1
	newSprite.y = gameTable[1].y*1 + display.contentCenterY
	newSprite:play()
	newSprite:setLinearVelocity( gameTable[1].vx*1, gameTable[1].vy*1 )
	

	newSprite:applyTorque(gameTable[1].torque*1)
end


function victory()
	print('win')
	
	if damage == 0 then
		audio.play(audio.loadSound( "sounds/" .. '237351__xtrgamr__parentsclapandcheer-02.wav' ))
		perfectText = display.newText( uiGroup, "PERFECT !!!", display.contentCenterX, display.contentCenterY-120, native.systemFont, 36 )
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
		
		loadbuttons('w')
		--[[
		--display.remove( body )
		if (level < 10) then
			loadbuttons('w')
		else
			loadfinal()
		end
		]]--
		
		composer.setVariable( "finalScore", score )
		saveLevel()
		saveMap()
		saveScores()
		
	else
		timer.performWithDelay(0,endgame, 1)
	end
end

local function gameLoop()
	
	
	-- Create new virus
	--print('Time : ' .. gameTable[1].time)
	--print('Item : ' .. gameTable[1].item)
	--print('lives : ' .. tostring(lives))
	--print(physics)

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
		print('pre win')
		pauseBtn:removeSelf()
		timer.performWithDelay(2*levels[level*1].delay*1,victory, 1)
		win = 1
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


local function waveLoop()

	gameTable = {}

	local function compare( a, b )
		return a.time*1 > b.time*1  -- Note ">" as the operator
	end
	 
	table.sort(waveTable,compare)

	print (waveTable[table.maxn(waveTable)].time)

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

local function lose()
	loadbuttons('l')
end

local function endGame()
	print('endgame')
	audio.pause(hearbeat)
	--background.alpha = 1
	background:setFillColor( .4 )
	--print('physics stop')
	physics.pause()
	--physics.stop()
	timer.pause(waveLoopTimer)
	timer.pause(gameLoopTimer)
	timer.performWithDelay(1000, lose)
	
end


local function onCollision( event )

	--print('lives: ' .. tostring(lives))
	--print('collision')
	--print('physics: ' .. tostring(physics))
	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "virus" and obj2.myName == "virus" ) or
			 ( obj1.myName == "virus" and obj2.myName == "virus" ) )
		then

				--[[
			for index, value in next, obj1 do
				print('bateu')
				print(index)
				print(value)
			end		
				]]--


			if (obj1.id*1 == 5) then
				cloneAsteroid(14,obj1.x,obj1.y)
			end
			if (obj2.id*1 == 5) then
				cloneAsteroid(14,obj2.x,obj2.y)					
			end

		elseif ( ( obj1.myName == "body" and obj2.myName == "virus" ) or
				 ( obj1.myName == "virus" and obj2.myName == "body" ) )
		then
			
			system.vibrate()
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
					--print('life change collision 0')
					--print(lives)
					--print(targets[objimpact.id*1].damage*1*shield)
					if (shield == 0 ) then
						lives = lives - math.floor( targets[objimpact.id*1].damage*1*0.5 )
					else	
						lives = lives - targets[objimpact.id*1].damage*1*shield
					end
				end
				livesText.text = "Life: " .. lives
				lifeBar.width = (display.actualContentWidth-50) * lives/lifeTotal
				if ( lives < 0.3 * lifeTotal ) then
					local heartbeat = audio.loadStream( "sounds/362374__shapingwaves__sw002-stethoscope-chest-heart-heartbeat-clean-at-heart.wav")
					audio.play(heartbeat, { channel=10, loops=-1 })
					audio.setVolume( 2, { channel=10 } )
					audio.pause( 3)
				else
					audio.play(soundTrack,{ channel=3})
					audio.pause(10)
				end
				if ( lives < 1 ) then
					pause = true
					--print('dead trigger')
					--print(physics)
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
			--print('colisão irrelevante')
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
	background = display.newImageRect(backGroup, "images/backgrounds/" .. backgrounds[levels[level*1].image*1].name, screenW-50, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background:setFillColor( .9 )

	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	--physics.addBody( body, "static", { friction=0.3 } )

	-- Display lives and score
	local stats = display.newRoundedRect( mainGroup ,display.screenOriginX+55, display.screenOriginY+5, 250,  30, 5  )
	stats:setFillColor(1,1,1,0.75)
	stats.anchorX = 0
	stats.anchorY = 0

	-- all display objects must be inserted into group
	display.setStatusBar( display.HiddenStatusBar )
	
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		print('scene show will')
		-- Called when the scene is still off screen and is about to move on screen

		map = event.params.map*1
		level = event.params.level*1
		loadData()
		loadUser()
		loadMusic()
		loadSword()

		-- create a body object and add physics (with custom shape)
		body = display.newRect( mainGroup ,display.screenOriginX, display.actualContentHeight + display.screenOriginY, display.contentWidth,  30  )
		body:setFillColor(black)
		body.anchorX = 0
		body.anchorY = 1
		--  draw the body at the very bottom of the screen
		--body.x, body.y = display.screenOriginX+30, display.actualContentHeight + display.screenOriginY
		body.myName = "body"
		physics.addBody( body, "static", { friction=0.3 } )

		if(levels[level*1].leftWall*1 > 0) then
			wallLeft = display.newRect( mainGroup ,display.screenOriginX, display.screenOriginY, 1, display.actualContentHeight + 50)
			wallLeft:setFillColor(white)
			wallLeft.anchorX = 0
			wallLeft.anchorY = 0
			wallLeft.x = - 25
			wallLeft.y = - 50
			--  draw the body at the very bottom of the screen
			--body.x, body.y = display.screenOriginX+30, display.actualContentHeight + display.screenOriginY
			wallLeft.myName = "Wall"
			physics.addBody( wallLeft, "static", { friction=0.0, bounce = levels[level*1].leftWall*1 } )
		end
		
		if(levels[level*1].rightWall*1 > 0) then
			wallRight = display.newRect( mainGroup ,display.screenOriginX + display.actualContentWidth, display.screenOriginY , 1, display.actualContentHeight+ 50)
			wallRight:setFillColor(white)
			wallRight.anchorX = 1
			wallRight.anchorY = 0
			wallRight.x =  display.actualContentWidth - 25
			wallRight.y = - 50
			--  draw the body at the very bottom of the screen
			--body.x, body.y = display.screenOriginX+30, display.actualContentHeight + display.screenOriginY
			wallRight.myName = "Wall"
			physics.addBody( wallRight, "static", { friction=0.0, bounce = levels[level*1].rightWall*1 } )
		end

		lifeBar = display.newRect( mainGroup , display.screenOriginX, display.actualContentHeight+ display.screenOriginY, display.actualContentWidth-50,  30  )
		lifeBar.anchorX = 0
		lifeBar.anchorY = 1
		lifeBar:setFillColor(1,0,0,1)

		
	
		livesText = display.newText( uiGroup, "Life: " .. lives, 100, 20, native.systemFont, 18 )
		livesText:setFillColor(0,0,0)
		scoreText = display.newText( uiGroup, "Score: " .. score, 175, 20, native.systemFont, 18 )
		scoreText:setFillColor(0,0,0)

		targetsText = display.newText( uiGroup, tostring(headCount) .. "/".. tostring(headTotal), 270, 20, native.systemFont, 18 )
		targetsText:setFillColor(0,0,0)

		-- SELECT -- 
		if(level > 7) then
			selectImg = display.newImageRect( mainGroup , "images/icons/suitcase.png", 45 , 45)
			selectImg.x= display.actualContentWidth-25
			selectImg.y = 70
			selectImg:addEventListener( "tap", loadInventory )
		end 
		
		-- WEAPONS --

		
		

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		print('scene show did')
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		--print('lives: ' .. tostring(lives))
		--print('collision')
		--print('physics: ' .. tostring(physics))

		--print(asteroidsTable)
		Runtime:addEventListener( "collision", onCollision )				
        waveLoopTimer = timer.performWithDelay( levels[level*1].delay*1, waveLoop, waves )
		--gameLoopTimer = timer.performWithDelay( levels[level*1].delay*1, gameLoop, interactions )
		
		Runtime:addEventListener( "enterFrame", function() collectgarbage("step") end )	
		--timer.performWithDelay( 2000, printMemUsage, -1 )	

		--it.timer1 = gameLoopTimer
		it.timer2 = waveLoopTimer
	
		pauseBtn = widget.newButton{
			label=" || ",
			labelColor = { default={0}, over={128} },
			shape = "circle",
			fillColor = { default={ 0.5, 0.5, 0.5, 0.8 }, over={ 0, 0.2, 1, 1 } },
			--default="button.png",
			--over="button-over.png",
			--width=50, height=50,
			radius=25,
			onRelease = onPauseRelease	-- event listener function
		}
		pauseBtn.anchorX = 1
		pauseBtn.anchorY = 0
		pauseBtn.x=display.actualContentWidth
		pauseBtn.y = 0

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
		print('scene hide will')
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
		print('scene hide did')
		Runtime:removeEventListener( "collision", onCollision )
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
	--timer.pause(waveLoopTimer)
	timer.cancel(waveLoopTimer)
	--timer.pause(gameLoopTimer)
	if gameLoopTimer then
		timer.cancel(gameLoopTimer)
	end
	if (pauseBtn) then
		pauseBtn:removeSelf()
	end
	Runtime:removeEventListener( "collision", onCollision )
	Runtime:removeEventListener( "enterFrame", function() collectgarbage("step") end )	
	audio.stop()
	destroyButtons()
	loadUser()
	cleanLevel()

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
