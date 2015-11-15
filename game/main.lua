require "jumper"
-- require "levelloader"
-- love.load() is called once when a LövePotion game is ran.
function love.load()
	J = jumper.Jumper:new(140,540, nil, -1, nil, nil, nil, false)

	-- Enables 3D mode.
	love.graphics.set3D(false)

	-- Seeds the random number generator with the time (Actually makes it random)
	math.randomseed(os.time())

	font = love.graphics.newFont() -- Creates a new font, when no arguments are given it uses the default font

	screens = {top = {w = 400, h = 240, margin = 47}, bottom = {w = 320, h = 240, margin = 7}}

	world = {gridsize= 18, grid = {}, litBlocks = {}}
	ypos = 1
	ymax = 480
	sunx = 9.0
	suny = 0

	-- initialize level to be empty air
	for y = 1, 50 do
		world.grid[y] = {}
	end

	for x = 3,14 do
		world.grid[6][x] = true
		world.grid[29][x] = true
	end
	for x = 7,9 do
		world.grid[10][x] = true
		world.grid[33][x] = true
	end

	-- for y = 1,48,2 do
	-- 	world.grid[y][8] = true
	-- end
	-- for y = 2,48,2 do
	-- 	world.grid[y][9] = true
	-- end

	-- set which blocks are lit initially
	checkForLitBlocks()

	-- Sets the background color
	love.graphics.setBackgroundColor(0,0,0)

	world.levelimg = love.graphics.newImage('level.png')
	overlay = love.graphics.newImage('overlaysun.png')
	-- overlay = love.graphics.newImage('overlay.png')

	lastKey = ''
end

-- love.draw() is called every frame. Any and all draw code goes here. (images, shapes, text etc.)
function love.draw()

	-- Draw bmp in proper place
	-- Start drawing to the top screen
	love.graphics.setColor(255, 255, 255)
	love.graphics.setScreen('top')
	love.graphics.draw(world.levelimg, screens.top.margin, 0 - (480 - ypos))
	love.graphics.setScreen('bottom')
	love.graphics.draw(world.levelimg, screens.bottom.margin, 0 - screens.top.h - (480 - ypos))

	-- Draw lit blocks
	for j, row in pairs(world.litBlocks) do
		for i, block in pairs(row) do
			local x = (i - 1) * world.gridsize
			local y = (j - 1) * world.gridsize - (480 - ypos)

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

	-- Draw jumper
	local Jsize = 10
	love.graphics.setColor(0,255,0)
	love.graphics.setScreen('top')
	love.graphics.rectangle('fill', screens.top.margin + J.pxpos.x - Jsize / 2, J.pxpos.y - (480 - ypos) - Jsize + 1, Jsize, Jsize)
	love.graphics.setScreen('bottom')
	love.graphics.rectangle('fill', screens.bottom.margin + J.pxpos.x - Jsize / 2, J.pxpos.y - (480 - ypos) - Jsize + 1 - screens.top.h, Jsize, Jsize)

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
	-- local sy = (suny - 1) * world.gridsize - (480 - ypos)
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
	if love.keyboard.isDown("cpadup") then
		ypos = ypos + 100 * dt
		if ypos > ymax then
			ypos = ymax
		end
		moved = true
	end

	if love.keyboard.isDown("cpaddown") then
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
	end

	if key == 'a' then
		J:jump(J.jump_v)
	end

	if key == 'dright' then
		J:move(2)
	end
	if key == 'dleft' then
		J:move(-2)
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
	local minvalidy = 5 + (480 - ypos) / world.gridsize
	local maxvalidy = 23 + (480 - ypos) / world.gridsize
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
