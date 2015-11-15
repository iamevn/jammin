-- love.load() is called once when a LövePotion game is ran.
function love.load()

	-- Enables 3D mode.
	love.graphics.set3D(false)

	-- Seeds the random number generator with the time (Actually makes it random)
	math.randomseed(os.time())

	font = love.graphics.newFont() -- Creates a new font, when no arguments are given it uses the default font

	screens = {offset = 40, top = {w = 400, h = 240}, bottom = {w = 320, h = 240}}

	sun = {pos = {x = 100, y = 100}, speed = 50, radius = 10, c = {r = 255, g = 255, b = 0}}
	world = {gridsize= 32, grid = {}}

	for y = 1, 480 / world.gridsize do
		world.grid[y] = {0}
		for x = 1, 320 / world.gridsize do
			world.grid[y][x] = {objtype = 'air', pos = {x = x, y = y}, lit = true}
		end
	end

	world.grid[6][3].objtype = 'block'
	world.grid[6][4].objtype = 'block'
	world.grid[6][5].objtype = 'block'

	world.grid[10][7].objtype = 'block'
	world.grid[10][8].objtype = 'block'
	world.grid[10][9].objtype = 'block'

	-- Sets the background color
	love.graphics.setBackgroundColor(0,0,0)



	lastKey = ''
	refresh = true
end

-- love.draw() is called every frame. Any and all draw code goes here. (images, shapes, text etc.)
function love.draw()

	-- Start drawing to the top screen
	love.graphics.setScreen('top')

	-- Reset the current draw color to white
	love.graphics.setColor(255, 255, 255)


	-- make a grid thing
	colors = {{r = 88, g = 186, b = 255}, {r = 20, g = 140, b = 255}}
	cix = 1

	if refresh then
		-- Draw world
		for j, row in ipairs(world.grid) do
			cix = cix % 2
			cix = cix + 1
			for i, v in ipairs(row) do
				if v.objtype == 'air' then
					love.graphics.setColor(colors[cix].r, colors[cix].g, colors[cix].b)
					if j * world.gridsize <= 300 then
						love.graphics.setScreen('top')
						love.graphics.rectangle('fill', i * world.gridsize - world.gridsize + screens.offset, j * world.gridsize - world.gridsize, world.gridsize, world.gridsize)
					end
					if j * world.gridsize >= 240 then
						love.graphics.setScreen('bottom')
						love.graphics.rectangle('fill', i * world.gridsize - world.gridsize, j * world.gridsize - screens.top.h - world.gridsize, world.gridsize, world.gridsize)
					end
				end
				cix = cix % 2
				cix = cix + 1
			end
		end
	end

	love.graphics.setScreen('top')
	-- Draws the framerate
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 10, 15, font:getWidth('FPS: ' .. love.timer.getFPS()) + 10, font:getHeight() + 3)
	love.graphics.setColor(35, 31, 32)
	love.graphics.setFont(font)
	love.graphics.print('FPS: ' .. love.timer.getFPS(), 15, 15)
	-- What was last key hit?
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', 10, 35, font:getWidth('lastKey: ' .. lastKey) + 10, font:getHeight() + 3)
	love.graphics.setColor(35, 31, 32)
	love.graphics.print('lastKey: ' .. lastKey, 15, 35)

	-- Draw sun
	love.graphics.setColor(sun.c.r, sun.c.g, sun.c.b)
	if sun.pos.y >= 240 - sun.radius then
		love.graphics.setScreen('bottom')
		love.graphics.circle('fill', sun.pos.x, sun.pos.y - screens.top.h, sun.radius, 100)
	end
	if sun.pos.y <= 240 + sun.radius then
		love.graphics.setScreen('top')
		love.graphics.circle('fill', sun.pos.x + screens.offset, sun.pos.y, sun.radius, 100)
	end
end

-- love.update(dt) is called every frame, and is used for game logic.
-- The dt argument is delta-time, the average time between frames.
-- Use this to make your game framerate independent.
function love.update(dt)
	if love.keyboard.isDown("cpadright") then
		sun.pos.x = sun.pos.x + sun.speed * dt
	end

	if love.keyboard.isDown("cpadleft") then
		sun.pos.x = sun.pos.x - sun.speed * dt
	end

	if love.keyboard.isDown("cpaddown") then
		sun.pos.y = sun.pos.y + sun.speed * dt
	end

	if love.keyboard.isDown("cpadup") then
		sun.pos.y = sun.pos.y - sun.speed * dt
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
	if key == 'a' then
		if refresh then
			refresh = false
		else
			refresh = true
		end
	end

end

-- love.quit is called when LövePotion is quitting.
-- You can put all your cleanup code and the likes here.
function love.quit()
	x = 1
end
