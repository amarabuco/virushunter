-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local storeRows 
local weaponsRows 
local itemsRows 

local tableView
local inventory

local activeTable = "inventory"
local balanceText
 

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

local function loadData()
 
	local filePath = system.pathForFile( "data/data.json" , system.ResourceDirectory )

	local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
		io.close( file )
		--dataTable = json.decode( contents )
        local decoded, pos, msg = json.decodeFile( filePath )
        sounds = decoded['sounds']
        store = decoded['store']
        weapons = decoded['weapons']
        items = decoded['items']
        backgrounds = decoded['backgrounds']
        
        storeRows = table.maxn( store )
        weaponsRows = table.maxn( weapons )
        itemsRows = table.maxn( items )

    end
end

local function loadUser()

	local db = {"maps","levels","scores","balance","user"}

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
			end
		end
	end
end

local function handleTabBarEvent( event )
    print( event.target.id )  -- Reference to button's 'id' parameter
end

local playBtn
local playBtn2


-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
    composer.removeScene( 'scenes.store')
    composer.gotoScene( "game", { effect = "crossFade", time = 500, params = { map = map, level = tostring(level)} })
	
	return true	-- indicates successful touch
end

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease2()
	
	-- go to level1.lua scene
    composer.removeScene( 'scenes.store')
    composer.gotoScene( "scenes.prelevel", { effect = "fade", time = 500, params = { map = map, level = tostring(level)} })
	
	return true	-- indicates successful touch
end

local function onPlayBtnRelease3()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.info", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function onMusicBtn()
	
	-- go to level1.lua scene
	audio.stop(1)
	--composer.gotoScene( "scenes.info", "fade", 500 )
	
	return true	-- indicates successful touch
end

local function saveDeal()

    --- UPDATE BALANCE
	local filePath = system.pathForFile( "balance.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( balanceTable ) )
        io.close( file )
    end
    
    --- INSERT DEALS
    local filePath = system.pathForFile( "deals.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( dealsTable ) )
        io.close( file )
    end

    --- INSERT WEAPONS
    local filePath = system.pathForFile( "weapons.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( weaponsTable ) )
        io.close( file )
    end

    --- INSERT ITEMS
    local filePath = system.pathForFile( "items.json", system.DocumentsDirectory )
	--print(filePath)

    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( itemsTable ) )
        io.close( file )
    end
end


local function onRowTouch( event )
   
    if ( event.phase == "tap" ) then
        print( event.target.id )  -- Reference to button's 'id' parameter
    end
end

local function buy( event )
    local key = event.target.id*1
    local balance = balanceTable[1]*1
    print( event.target.id )  -- Reference to button's 'id' parameter
    if(store[key].price*1 < balance ) then
        table.insert(dealsTable,{id = os.date('%Y%m%d%H%M%S'), item=store[key].item, qtd=store[key].qtd, price=store[key].price, date = os.date('%Y-%m-%d %H:%M:%S') })
        balanceTable[1] = balance*1- store[key].price*1
        if(store[key].type*1 == 1 ) then
            local weaponId = nil
            for index, value in next, weaponsTable do
                if (value['weapon'] ~= nil and value['weapon']*1 == store[key].item*1) then
                    weaponId = index
                    break
                end
            end
            if (weaponId == nil) then
                table.insert(weaponsTable,{weapon=store[key].item, qtd=store[key].qtd*1 })
            else
                local qtd = weaponsTable[weaponId].qtd
                weaponsTable[weaponId] = {weapon=store[key].item, qtd= qtd + store[key].qtd*1  }
            end
        elseif(store[key].type*1 == 2 ) then
            local itemId = nil
            for index, value in next, itemsTable do
                if (value['item'] ~= nil and value['item']*1 == store[key].item*1) then
                    itemId = index
                    break
                end
            end
            if (itemId == nil) then
                table.insert(itemsTable,{item=store[key].item, qtd=store[key].qtd*1 })
            else
                local qtd = itemsTable[itemId].qtd
                itemsTable[itemId] = {item=store[key].item, qtd= qtd + store[key].qtd*1  }
            end
        end

        balanceText.text = "$" .. tostring(balanceTable[1])
        --balanceText:setFillColor(0)
        saveDeal()
        local buySound = audio.loadSound( "sounds/201159__kiddpark__cash-register.wav" )
        audio.play(buySound)
        
    else
        local alert = native.showAlert( "No Deal", "Not enought money or capacity.", { "OK" } )
        balanceText:setFillColor(1,0,0,1)
        --balanceText:setStrokeColor( 1 )
        local errorSound = audio.loadSound( "sounds/450616__breviceps__8-bit-error.wav" )
        audio.play(errorSound)
    end
end

local function onRowRender( event )
 
    -- Get reference to the row group
    local row = event.row
    local rowData = event.row.params

    for index, value in next, rowData do
        --print(index .. tostring(value))
        --print(item)
        print(value)
        --[[
        for index, value in next, item do
            print(index .. tostring(value))
        end
        ]]--
    end
 
    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
 
    local id = display.newText( row, rowData.id, 0, 0, nil, 14 )
    local name = display.newText( row, rowData.name, 0, 0, nil, 14 )
    if (rowData.image == 'image') then
        local image = display.newText( row, rowData.image, 0, 0, nil, 14 )
        image:setFillColor( 0 )
        image.anchorX = 0
        image.x = rowWidth * 0.3
        image.y = rowHeight * 0.5

        local shop = display.newText( row, 'Buy', 0, 0, nil, 14 )
        shop:setFillColor( 0 )
        shop.anchorX = 0
        shop.x = rowWidth * 0.9
        shop.y = rowHeight * 0.5

    elseif (rowData.image ~= nil) then
        local image
        print(rowData.name)
        if(rowData.type*1 == 1) then
            image = display.newImageRect( row, "images/weapons/" .. rowData.image, 25, 25 )
        elseif(rowData.type*1 == 2) then
            image = display.newImageRect( row, "images/items/" .. rowData.image, 25, 25 )
        end
        image.anchorX = 0
        image.x = rowWidth * 0.3
        image.y = rowHeight * 0.5

        local shop = display.newImageRect( row, "images/icons/cart.png", 20, 20 )
        shop.anchorX = 0
        shop.x = rowWidth * 0.9
        shop.y = rowHeight * 0.5
        shop.id = rowData.id
        shop:addEventListener('tap', buy)
    end
    local price = display.newText( row, '$'.. tostring(rowData.price), 0, 0, nil, 14 )
    local unit = display.newText( row, rowData.qtd, 0, 0, nil, 14 )
    id:setFillColor( 0 )
    name:setFillColor( 0 )
    price:setFillColor( 0 )
    unit:setFillColor( 0 )
   
 
    -- Align the label left and vertically centered
    id.anchorX = 0
    id.x = rowWidth * 0.05
    id.y = rowHeight * 0.5
    
    name.anchorX = 0
    name.x = rowWidth * 0.1
    name.y = rowHeight * 0.5
    
    price.anchorX = 0
    price.x = rowWidth * 0.5
    price.y = rowHeight * 0.5
    
    unit.anchorX = 0
    unit.x = rowWidth * 0.7
    unit.y = rowHeight * 0.5

end

local function onRowRender2( event )
 
    -- Get reference to the row group
    local row = event.row
    local rowData = event.row.params
 
    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
 
    local name = display.newText( row, rowData.name, 0, 0, nil, 14 )
    print(rowData.image)
    if (rowData.image == 'image') then
        local image = display.newText( row, rowData.image, 0, 0, nil, 14 )
        image:setFillColor( 0 )
        image.anchorX = 0
        image.x = rowWidth * 0.5
        image.y = rowHeight * 0.5
    elseif (rowData.image ~= nil) then
        print(rowData.name)
        local image 
        if(rowData.type*1 == 1) then
            image = display.newImageRect( row, "images/weapons/" .. rowData.image, 25, 25 )
        elseif(rowData.type*1 == 2) then
            image = display.newImageRect( row, "images/items/" .. rowData.image, 25, 25 )
        end
        image.anchorX = 0
        image.x = rowWidth * 0.5
        image.y = rowHeight * 0.5
    end
    local unit = display.newText( row, rowData.qtd, 0, 0, nil, 14 )
    name:setFillColor( 0 )
    unit:setFillColor( 0 )
   
 
    -- Align the label left and vertically centered
    name.anchorX = 0
    name.x = rowWidth * 0.05
    name.y = rowHeight * 0.5
   
    unit.anchorX = 0
    unit.x = rowWidth * 0.7
    unit.y = rowHeight * 0.5

end

local function toMenu()
    
        composer.removeScene('prelevel')
        composer.gotoScene( "menu")
	
	return true	-- indicates successful touch
end

local function loadButtons()
    
    
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
		onRelease = onPlayBtnRelease2	-- event listener function
	}
	playBtn2.x = 30
    playBtn2.y = display.contentHeight - 40
    

return true	-- indicates successful touch
end


local function loadShop()

    --- SHOP ---
    display.remove(playBtn)
    display.remove(playBtn2)
    inventory:removeSelf()
    inventory = nil

    activeTable = 'shop'

     tableView = widget.newTableView(
        {
            top = 100,
            left = 0,
            width = display.actualContentWidth,
            --width = 500, 
            height = (storeRows - 2)  * 30,
            onRowRender = onRowRender,
            --onRowTouch = onRowTouch,
            listener = scrollListener
        }
    )

    local isCategoryHeader = true
    local rowHeightHeader = 36
    local rowColorHeader = { default={0.6,0.6,0.6,1}, over={1,0.5,0,0.2} }
    local lineColorHeader = { 0, 0, 0 }

    local isCategoryLineEven = false
    local rowHeightLineEven = 30
    local rowColorLineEven = { default={0.8,0.8,0.8,1}, over={1,0.5,0,0.2} }
    local lineColorLineEven = { 1, 1, 1 }
  
    local isCategoryLineOdd = false
    local rowHeightLineOdd = 30
    local rowColorLineOdd = { default={1,1,1,0.5}, over={1,0.5,0,0.2} }
    local lineColorLineOdd = { 1, 1, 1 }
    
    tableView:insertRow(
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
                price = "price",
                qtd = "units"
            }
        }
    )

    tableView:insertRow(
        {
            isCategory = false,
            rowHeight = 40,
            rowColor = { default={1,0,0,0.6}, over={1,0.5,0,0.2} },
            --lineColor =  { 1, 1, 1 },
            params = {
                id = "",
                name = "WEAPONS",
                image = nil,
                type = "",
                price = "",
                qtd = ""
            }
        }
    )

    for index, item in next, store do
        if (item.type*1 == 1 ) then
        if (index % 2 == 0 ) then
            tableView:insertRow{
            isCategory = isCategoryLineEven,
            rowHeight = rowHeightLineEven,
            rowColor = rowColorLineEven,
            lineColor = lineColorLineEven,  
            params = {
                id = item.id,
                name = item.name,
                image = item.image,
                type = item.type,
                price = item.price,
                qtd = item.qtd
                }
            }
        else
            tableView:insertRow{
                isCategory = isCategoryLineOdd,
                rowHeight = rowHeightLineOdd,
                rowColor = rowColorLineOdd,
                lineColor = lineColorLineOdd,  
                params = {
                    id = item.id,
                    name = item.name,
                    image = item.image,
                    type = item.type,
                    price = item.price,
                    qtd = item.qtd
                    }
                }
            end
        end

    end
    --sceneGroup:insert( tableView )

    tableView:insertRow(
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
                price = "",
                qtd = ""
            }
        }  
    )

    for index, item in next, store do
        if (item.type*1 == 2 ) then
            if (index % 2 == 0 ) then
                tableView:insertRow{
                isCategory = isCategoryLineEven,
                rowHeight = rowHeightLineEven,
                rowColor = rowColorLineEven,
                lineColor = lineColorLineEven,  
                params = {
                    id = item.id,
                    name = item.name,
                    image = item.image,
                    type = item.type,
                    price = item.price,
                    qtd = item.qtd
                    }
                }
            else
                tableView:insertRow{
                    isCategory = isCategoryLineOdd,
                    rowHeight = rowHeightLineOdd,
                    rowColor = rowColorLineOdd,
                    lineColor = lineColorLineOdd,  
                    params = {
                        id = item.id,
                        name = item.name,
                        image = item.image,
                        type = item.type,
                        price = item.price,
                        qtd = item.qtd
                        }
                    }
                end
            end            
    end

    loadButtons()

return true	-- indicates successful touch
end

local function loadInventory()
    
    -- INVENTORY --
    if(tableView) then
        display.remove(playBtn)
        display.remove(playBtn2)
        tableView:removeSelf()
        tableView = nil
     end

    activeTable = 'inventory'

    inventory = widget.newTableView(
        {
            top = 100,
            left = 0,
            width = display.actualContentWidth,
            --width = 500, 
            height = weaponsRows * 15 + (itemsRows) * 15,
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

    inventory:insertRow(
        {
            isCategory = isCategoryHeader,
            rowHeight = rowHeightHeader,
            rowColor = rowColorHeader,
            lineColor = lineColorHeader,
            params = {
                name = "name",
                image = "image",
                type = "type",
                qtd = "units"
            }
        }
    )

    inventory:insertRow(
        {
            isCategory = false,
            rowHeight = 40,
            rowColor = { default={1,0,0,0.6}, over={1,0.5,0,0.2} },
            --lineColor =  { 1, 1, 1 },
            params = {
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
            inventory:insertRow{
            isCategory = isCategoryLineEven,
            rowHeight = rowHeightLineEven,
            rowColor = rowColorLineEven,
            lineColor = lineColorLineEven,  
            params = {
                name = weapons[item.weapon*1].name,
                image = weapons[item.weapon*1].image,
                type = 1,
                qtd = item.qtd
                }
            }
        else
            inventory:insertRow{
                isCategory = isCategoryLineOdd,
                rowHeight = rowHeightLineOdd,
                rowColor = rowColorLineOdd,
                lineColor = lineColorLineOdd,  
                params = {
                    name = weapons[item.weapon*1].name,
                    image = weapons[item.weapon*1].image,
                    type = 1,
                    qtd = item.qtd
                    }
                }
            end
    end

    inventory:insertRow(
        {
            isCategory = false,
            rowHeight = 40,
            rowColor = { default={0,0,1,0.5}, over={1,0.5,0,0.2} },
            --lineColor =  { 1, 1, 1 },
            params = {
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
            inventory:insertRow{
            isCategory = isCategoryLineEven,
            rowHeight = rowHeightLineEven,
            rowColor = rowColorLineEven,
            lineColor = lineColorLineEven,  
            params = {
                name = items[item.item*1].name,
                image = items[item.item*1].image,
                type = 2,
                qtd = item.qtd
                }
            }
        else
            inventory:insertRow{
                isCategory = isCategoryLineOdd,
                rowHeight = rowHeightLineOdd,
                rowColor = rowColorLineOdd,
                lineColor = lineColorLineOdd,  
                params = {
                    name = items[item.item*1].name,
                    image = items[item.item*1].image,
                    type = 2,
                    qtd = item.qtd
                    }
                }
            end
    end

    loadButtons()

return true	-- indicates successful touch
end

-- forward declarations and other locals


function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
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

        loadUser()
        print(balanceTable[1])
        
        loadData()
        print('store')
        

        map = event.params.map*1
        if event.params.level ~= nil then
            level = event.params.level*1
        else
            toMenu()
        end

        local tabButtons = {
            {
                label = "< SHOP >",
                id = "tab1",
                size = 18,
                --defaultFile = "images/buttons/button.png",
                --overFile = "images/buttons/button_over.png",
                --labelYOffset = -15,
                width = 150, 
                height = 40,                
                onPress = loadShop
            },
            {
                label = "< INVENTORY >",
                id = "tab2",
                --defaultFile = "images/buttons/button.png",
                --overFile = "images/buttons/button_over.png",
                --labelYOffset = -15,
                width = 150, 
                height = 40,
                size = 18,
                selected = true,
                onPress = loadInventory
            }
        }

        local tabBar = widget.newTabBar(
            {
                top = 50,
                left = 0,
                width = display.contentWidth,
                buttons = tabButtons
            }
        )

    local filePath = system.pathForFile( "images/intro/" .. level ..".jpeg" , system.ResourceDirectory )
    print(filePath)

    background = display.newImageRect( "images/intro/0.jpeg", display.actualContentWidth , display.actualContentHeight )
    --background = display.newRect( 0, 0, display.actualContentWidth, 60,20 )
    --background = display.newImage("images/intro/0.jpeg" )
    background.anchorX = 0 
    background.anchorY = 0
    background.x = -30

	-- create a widget button (which will loads level1.lua on release)
    local descricao
    local titleCover
    
    descricao = display.newText( 'STORE', display.contentCenterX, 15, native.systemFont, 22 )
    descricao:setFillColor(1,1,1,1)
    titleCover = display.newRect( 0, 0, display.actualContentWidth+50, 60,20 )
    titleCover.anchorX=0
    titleCover:setFillColor( 1,1,1,0.2 )

    loadInventory()
  

    --balanceText = display.newText( uiGroup, 'Balance: ' .. tostring(balanceTable[1]), display.screenOriginX+50, display.screenOriginY + 40, native.systemFont, 16 )
    balanceText = display.newText( '$' .. tostring(balanceTable[1]), 10 ,75, native.systemFont, 16 )
    balanceText.anchorX = 0
    balanceText:setFillColor(0)

	-- all display objects must be inserted into group
    --sceneGroup:insert( background )
    
    sceneGroup:insert( background )
    sceneGroup:insert( tabBar )
    sceneGroup:insert( descricao )
    sceneGroup:insert( titleCover )
    
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
    display.remove(playBtn)
    display.remove(playBtn2)
    display.remove(background)
    display.remove(balanceText)
    print('tableView')
    print(tableView)
    print('inventory')
    print(inventory)
    
    if (activeTable == 'shop') then
        tableView:removeSelf()
        tableView = nil
    else
        inventory:removeSelf()
        inventory = nil
    end
    
    print('tableView2')
    print(tableView)
    print('inventory2')
    print(inventory)

    audio.stop()
		
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene