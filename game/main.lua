require "jumper"
require "levelloader"
-- love.load() is called once when a LövePotion game is ran.
currentLevel = "level1.txt"
function love.load()
    win = love.graphics.newImage('win.png')
    -- Enables 3D mode.
    love.graphics.set3D(false)

    -- Seeds the random number generator with the time (Actually makes it random)
    math.randomseed(os.time())

    font = love.graphics.newFont() -- Creates a new font, when no arguments are given it uses the default font

    -- load jump sound
    jsound = love.audio.newSource("jump.wav")

    screens = {top = {w = 400, h = 240, margin = 47}, bottom = {w = 320, h = 240, margin = 7}}

    world = {gridsize= 18, grid = {}, litBlocks = {}}
    sunx = 9.0
    suny = 0

    L = levelloader.loadlevel(currentLevel)
    ymax = world.gridsize * #L.plat
    world.grid = L.plat
    Jsize = 10
    local px = L.start.x * world.gridsize + Jsize / 2
    local py = L.start.y * world.gridsize - world.gridsize
    J = jumper.Jumper:new(px,py, nil, 0, nil, nil, nil, function() jsound:play() end, true)
    -- J = jumper.Jumper:new(px,py, nil, 0, nil, nil, nil, nil, false)
    ypos = ymax - J.pxpos.y + 250

    -- set which blocks are lit initially
    checkForLitBlocks()

    -- Sets the background color
    love.graphics.setBackgroundColor(0,0,0)

    world.levelimg = love.graphics.newImage('level.png')
    overlay = love.graphics.newImage('overlaysun.png')
    flag = {img = love.graphics.newImage("flag.png"), pos = {x=L.goal.x, y=L.goal.y - 1}}
    clearSound = love.audio.newSource("clear.wav")

    lastKey = ''
    ded = false
    dedSound = love.audio.newSource("ded.wav")
    atGoal = false
    aWinner = false
end

-- love.draw() is called every frame. Any and all draw code goes here. (images, shapes, text etc.)
function love.draw()
    if aWinner then
	love.graphics.setScreen('top')
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(win, 0,0)
	return
    end


    -- Draw bmp in proper place
    -- Start drawing to the top screen
    love.graphics.setColor(255, 255, 255)
    love.graphics.setScreen('top')
    love.graphics.draw(world.levelimg, screens.top.margin, 0 - (ymax - ypos))
    love.graphics.setScreen('bottom')
    love.graphics.draw(world.levelimg, screens.bottom.margin, 0 - screens.top.h - (ymax - ypos))

    -- Draw lit blocks
    for j, row in pairs(world.litBlocks) do
	for i, block in pairs(row) do
	    local x = (i - 1) * world.gridsize
	    local y = (j - 1) * world.gridsize - (ymax - ypos)

	    if y <= 300 then
		love.graphics.setScreen('top')
		love.graphics.rectangle('fill', x + screens.top.margin, y, world.gridsize, world.gridsize)
	    end
	    if y >= 200 then
		love.graphics.setScreen('bottom')
		love.graphics.rectangle('fill', x + screens.bottom.margin, y - screens.top.h, world.gridsize, world.gridsize)
	    end
	end
    end

    local goalx = (flag.pos.x - 1) * world.gridsize
    local goaly = (flag.pos.y - 1) * world.gridsize - (ymax - ypos)
    if goaly <= 300 then
	love.graphics.setScreen('top')
	love.graphics.draw(flag.img, goalx + screens.top.margin, goaly, world.gridsize, world.gridsize)
    end
    if goaly >= 200 then
	love.graphics.setScreen('bottom')
	love.graphics.draw(flag.img, goalx + screens.bottom.margin, goaly - screens.top.h, world.gridsize, world.gridsize)
    end

    -- Draw jumper
    love.graphics.setColor(0,255,0)
    love.graphics.setScreen('top')
    love.graphics.rectangle('fill', screens.top.margin + J.pxpos.x - Jsize / 2, J.pxpos.y - (ymax - ypos) - Jsize + 1, Jsize, Jsize)
    love.graphics.setScreen('bottom')
    love.graphics.rectangle('fill', screens.bottom.margin + J.pxpos.x - Jsize / 2, J.pxpos.y - (ymax - ypos) - Jsize + 1 - screens.top.h, Jsize, Jsize)

    -- Draw sun 
    -- does this break things?
    -- looks like it does.
    --    https://github.com/VideahGams/LovePotion/issues/3
    --    https://github.com/xerpi/sf2dlib/issues/9
    -- love.graphics.setColor(255,255,0, 120)
    -- love.graphics.setScreen('top')
    -- love.graphics.circle('fill', screens.top.w / 2, screens.top.h, 20, 50)
    -- love.graphics.setScreen('bottom')
    -- love.graphics.circle('fill', screens.bottom.w / 2, 0, 20, 50)
    -- Since drawing the sun broke things, let's put the sun as part of the overlay instead.

    love.graphics.setColor(255,255,255,255)

    -- Draw shadow overlay
    love.graphics.setColor(255,255,255,255)
    love.graphics.setScreen('top')
    love.graphics.draw(overlay, 0,0)
    love.graphics.setScreen('bottom')
    love.graphics.draw(overlay, 0 - (screens.top.margin - screens.bottom.margin), 0 - screens.top.h)

    --text stuff
    love.graphics.setScreen('top')
    -- Draws the framerate
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', 10, 15, font:getWidth('FPS: ' .. love.timer.getFPS()) + 10, font:getHeight() + 3)
    love.graphics.setColor(35, 31, 32)
    love.graphics.setFont(font)
    love.graphics.print('FPS: ' .. love.timer.getFPS(), 15, 15)
    -- how many blocks are lit?
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', 10, 35, font:getWidth('litBlocks: ' .. litCount) + 10, font:getHeight() + 3)
    love.graphics.setColor(35, 31, 32)
    love.graphics.print('litBlocks: ' .. litCount, 15, 35)
    love.graphics.setColor(255,255,255)
    local str = 'sun at: (' .. math.floor(sunx) .. ', ' .. math.floor(suny) .. ')'
    love.graphics.rectangle('fill', 10, 55, font:getWidth(str) + 10, font:getHeight() + 3)
    love.graphics.setColor(35, 31, 32)
    love.graphics.print(str, 15, 55)

    -- draw sun pos for test purposes
    -- love.graphics.setColor(255,255,0,255)
    -- local sx = (sunx - 1) * world.gridsize
    -- local sy = (suny - 1) * world.gridsize - (ymax - ypos)
    -- if sy <= 300 then
    -- 	love.graphics.setScreen('top')
    -- 	love.graphics.rectangle('fill', sx + screens.top.margin, sy, world.gridsize, world.gridsize)
    -- end
    -- if sy >= 200 then
    -- 	love.graphics.setScreen('bottom')
    -- 	love.graphics.rectangle('fill', sx + screens.bottom.margin, sy - screens.top.h, world.gridsize, world.gridsize)
    -- end
end

-- love.update(dt) is called every frame, and is used for game logic.
-- The dt argument is delta-time, the average time between frames.
-- Use this to make your game framerate independent.
function love.update(dt)
    local moved = false
    -- if love.keyboard.isDown("cpadup") then
    if love.keyboard.isDown("dup") then
	ypos = ypos + 100 * dt
	if ypos > ymax then
	    ypos = ymax
	end
	moved = true
    end

    -- if love.keyboard.isDown("cpaddown") then
    if love.keyboard.isDown("ddown") then
	ypos = ypos - 100 * dt
	if ypos < 0 then
	    ypos = 0
	end
	moved = true
    end
    if moved then
	-- update litBlocks
	checkForLitBlocks()
    end

    if love.keyboard.isDown("a") then
	J:jump(J.jump_v)
    end
    J:update(dt, world.litBlocks, 18)
    if J.pxpos.y > ymax then
	rip()
    end
    if (not atGoal) and playerInGoal(J.pxpos, flag.pos) then
	atGoal = true
	clearSound:play()
    end
end

-- love.keypressed is called when any button is pressed.
-- The argument key is the key that was pressed.
-- Not all input code goes here, if you want to check if a button is down then
-- use love.update(dt) along with love.keyboard.isDown().
function love.keypressed(key)
    lastKey = key

    -- If the start button is pressed, we return to the Homebrew Launcher
    if key == 'start' then
	love.event.quit()
    elseif atGoal then
	nextLevel()
    end

    if key == 'select' then
	love.load()
    end

    if key == 'a' then
	J:jump(J.jump_v)
    end

    if key == 'dright' then
	J:move(1)
    end
    if key == 'dleft' then
	J:move(-1)
    end
end

-- called when any button is released
function love.keyreleased(key)
    if key == 'a' then
	J:clipWings()
    end

    if key == 'dright' or key == 'dleft' then
	J:move(0)
    end
end

-- love.quit is called when LövePotion is quitting.
-- You can put all your cleanup code and the likes here.
-- (don't need it)
-- function love.quit()
-- 	x = 1
-- end

-- called whenever the screen changes (should call on load)
-- checks whether blocks in level are within the lit area (just check those that are in the right y range)
function checkForLitBlocks()
    local t = {}
    litCount = 0
    local minvalidy = 5 + (ymax - ypos) / world.gridsize
    local maxvalidy = 23 + (ymax - ypos) / world.gridsize
    --sunx never changes
    -- sunx = 9
    suny = round((maxvalidy - minvalidy) / 2) + minvalidy
    for j, row in pairs(world.grid) do
	if j and j >= minvalidy and j <= maxvalidy then
	    for i, b in pairs(row) do
		if checkLit(i,j) then
		    if not t[j] then
			t[j] = {}
		    end
		    t[j][i] = true
		    litCount = litCount + 1
		end
	    end
	end
    end
    world.litBlocks = t
end

-- given an x, y coordinate, is there a clear path from it to the center of the screen?
function checkLit(x, y)
    -- local sx = sunx
    local sx = 9
    local sy = suny

    if sx == x and sy == y then return true end

    T = bresenhamLine(x, y, sx, sy)
    if #T <= 3 then return true end

    for n = 2, #T -1 do
	i,j = T[n].x, T[n].y
	if world.grid[j] and world.grid[j][i] then
	    return false
	end
    end
    -- for i, j in bresenhamLine(x, y, sx, sy) do
    -- 	if world.grid[j] and world.grid[j][i] then
    -- 		return false
    -- 	end
    -- end
    return true
end

-- given two x, y coordinates, returns an interator sort of thing
-- that consists of each point on the line between them
-- (starting at first one and ending just before last one)
function bresenhamLine(x0, y0, x1, y1)
    local T = {}
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local x, y = x0, y0
    local sx, sy = 1, 1
    if x0 > x1 then sx = -1 end
    if y0 > y1 then sy = -1 end
    if dx > dy then
	local err = dx / 2
	while round(x) ~= round(x1) do 
	    table.insert(T, {x=x, y=y})
	    err = err - dy
	    if err < 0 then
		y = y + sy
		err = err + dx
	    end
	    x = x + sx
	end
    else
	local err = dy / 2
	while round(y) ~= round(y1) do
	    table.insert(T, {x=x, y=y})
	    err = err - dx
	    if err < 0 then
		x = x + sx
		err = err + dy
	    end
	    y = y + sy
	end
    end
    table.insert(T, {x=x, y=y})
    -- local n = 0
    -- return function ()
    -- 	if n < #T then
    -- 		n = n + 1
    -- 		return T[n].x, T[n].y
    -- 	end
    -- end
    return T
end

function round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
	return under
    else
	return upper
    end
end

function rip()
    if not ded then
	ded = true
	dedSound:play()
    end
end

function playerInGoal(playerPXPos, flagVirtPos)
    playerVirtX = math.ceil(playerPXPos.x / world.gridsize)
    playerVirtY = math.ceil(playerPXPos.y / world.gridsize)

    return math.abs(playerVirtX - flagVirtPos.x) < 0.1  and math.abs(playerVirtY - (flagVirtPos.y + 0)) < 0.1
end

function nextLevel()
    if aWinner then return end

    if currentLevel == "level1.txt" then
	currentLevel = "level2.txt"
    elseif currentLevel == "level2.txt" then
	currentLevel = "level3.txt"
    elseif currentLevel == "level3.txt" then
	currentLevel = "level4.txt"
    else
	victory()
    end

    love.load()
end

function victory()
    aWinner=true
    -- vmusic = love.audio.newSource("victory.wav")
    -- vmusic:play()
    -- while vmusic.isPlaying do
	-- local x = 1
    -- end
end
