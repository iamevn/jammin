-- love.load() is called once when a LövePotion game is ran.
function love.load()

	-- Enables 3D mode.
	love.graphics.set3D(false)

	-- Seeds the random number generator with the time (Actually makes it random)
	math.randomseed(os.time())

	font = love.graphics.newFont() -- Creates a new font, when no arguments are given it uses the default font

	screens = {offset = 40, top = {w = 400, h = 240}, bottom = {w = 320, h = 240}}
	
	sun = {pos = {x = 100, y = 100}, speed = 50, radius = 10, c = {r = 255, g = 255, b = 0}}
	world = {gridsize = 5}

 	-- Sets the background color to a nice blue
	love.graphics.setBackgroundColor(88, 186, 255)
	lastKey = ''

end

-- love.draw() is called every frame. Any and all draw code goes here. (images, shapes, text etc.)
function love.draw()

	-- Start drawing to the top screen
	love.graphics.setScreen('top')

	-- Reset the current draw color to white
	love.graphics.setColor(255, 255, 255)

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

	love.graphics.setColor(255, 255, 255)


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

end

-- love.quit is called when LövePotion is quitting.
-- You can put all your cleanup code and the likes here.
function love.quit()
	x = 1
end
