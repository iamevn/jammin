-- love.load() is called once when a LövePotion game is ran.
function love.load()

	-- Enables 3D mode.
	love.graphics.set3D(false)

	-- Seeds the random number generator with the time (Actually makes it random)
	math.randomseed(os.time())

	font = love.graphics.newFont() -- Creates a new font, when no arguments are given it uses the default font

	screens = {offset = 40, top = {w = 400, h = 240}, bottom = {w = 320, h = 240}}

	-- sun = {pos = {x = 100, y = 100}, speed = 50, radius = 10, c = {r = 255, g = 255, b = 0}}
	world = {gridsize= 20, grid = {}, litBlocks = {}}
	ypos = 1
	ymax = 480

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

	lastKey = ''
end

-- love.draw() is called every frame. Any and all draw code goes here. (images, shapes, text etc.)
function love.draw()

	-- Draw bmp in proper place
	-- Start drawing to the top screen
	love.graphics.setColor(255, 255, 255)
	love.graphics.setScreen('top')
	love.graphics.draw(world.levelimg, screens.offset, 0 - (480 - ypos))
	love.graphics.setScreen('bottom')
	love.graphics.draw(world.levelimg, 0, 0 - screens.top.h - (480 - ypos))

	-- Draw lit blocks
	for i, block in ipairs(world.litBlocks) do
		local x = (block.x - 1) * world.gridsize
		local y = (block.y - 1) * world.gridsize - (480 - ypos)

		if y <= 300 then
			love.graphics.setScreen('top')
			love.graphics.rectangle('fill', x + screens.offset, y, world.gridsize, world.gridsize)
		end
		if y >= 200 then
			love.graphics.setScreen('bottom')
			love.graphics.rectangle('fill', x, y - screens.top.h, world.gridsize, world.gridsize)
		end
	end

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
	love.graphics.draw(overlay, 0 - screens.offset, 0 - screens.top.h)

	love.graphics.setScreen('top')
	-- Draws the framerate
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 10, 15, font:getWidth('FPS: ' .. love.timer.getFPS()) + 10, font:getHeight() + 3)
	love.graphics.setColor(35, 31, 32)
	love.graphics.setFont(font)
	love.graphics.print('FPS: ' .. love.timer.getFPS(), 15, 15)
	-- how many blocks are lit?
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 10, 35, font:getWidth('litBlocks: ' .. #world.litBlocks) + 10, font:getHeight() + 3)
	love.graphics.setColor(35, 31, 32)
	love.graphics.print('litBlocks: ' .. #world.litBlocks, 15, 35)
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

end

-- love.quit is called when LövePotion is quitting.
-- You can put all your cleanup code and the likes here.
-- (don't need it)
-- function love.quit()
-- 	x = 1
-- end

-- given an x, y coordinate, is there a clear path from it to the center of the screen?
function checkLit(x, y)
	return true
end

-- called whenever the screen changes (should call on load)
-- checks whether blocks in level are within the lit area (just check those that are in the right y range)
function checkForLitBlocks()
	t = {}
	minvalidy = 5 + (480 - ypos) / world.gridsize
	maxvalidy = 20 + (480 - ypos) / world.gridsize
	for j, row in pairs(world.grid) do
		if j and j >= minvalidy and j <= maxvalidy then
			for i, b in pairs(row) do
				if checkLit(i,j) then
					table.insert(t, {x = i, y = j})
				end
			end
		end
	end
	world.litBlocks = t
end

