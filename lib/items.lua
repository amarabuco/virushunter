-----------------------------------------------------------------------------------------
--
-- items.lua
--
-----------------------------------------------------------------------------------------

local I = {}
 
print( "items.lua has been loaded" )
  
I.test = function(level)
    print (level)   
end

I.time = 0
I.gx = 0
I.gy = 0
I.timer1 = ''
I.timer2 = ''
I.life = 0

I.resumeGravity = function ()
    --print('Newton Rules')
    physics.setGravity(I.gx, I.gy)
    background:setFillColor( 1 )
end

I.push = function ()
    print('slow')
    print(I.time)
    print(I.gx)
    print(I.gy)
    physics.setGravity(0, -5)
    timer.performWithDelay( I.time, I.resumeGravity )
end

I.heal = function ()
    if I.life == 1 then
        lives = lives + 1
    elseif I.life == 2 then
        lives = lives + 2
    elseif I.life == 3 then
        lives = lives + 3
    end
        livesText.text = "Life: " .. lives
end

I.shield = function ()
    shield = 0 
    shieldBody = display.newRect( display.screenOriginX, display.actualContentHeight+ display.screenOriginY-30, display.actualContentWidth,  30  )
    shieldBody.anchorX = 0
    shieldBody.anchorY = 1
    shieldBody:setFillColor(0,0,1,0.8)
end

I.slow = function ()
    physics.setGravity(0, 0)
    timer.performWithDelay( I.time, I.resumeGravity )
    background:setFillColor( 1, 1, 0, 1 )    
end

I.push = function ()
    physics.setGravity(0, -5)
    timer.performWithDelay( I.time, I.resumeGravity )
end

I.resumeTimer = function ()
    background:setFillColor( 1 )
    physics.start()

    timer.resume(I.timer2)
    
end

I.stop = function ()
    print('stop')
    physics.pause()
    print(I.timer1)
    print(I.timer2)
    print(I.gy)
    --timer.pause(I.timer1)
    if I.timer2 then
        timer.pause(I.timer2)
    end
    
    background:setFillColor( 1, 0, 0, 0.95 )  

    timer.performWithDelay( I.time, I.resumeTimer )
end

return I