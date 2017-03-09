require "player"
require "world"
require "music"
Timer = require 'lib/timer'
require 'lib/TEsound'

smallFont = love.graphics.newFont('fonts/Sansation_Regular.ttf', 16)
mainFont = love.graphics.newFont('fonts/Sansation_Regular.ttf', 24)
largeFont = love.graphics.newFont('fonts/Sansation_Regular.ttf', 32)

TIME_MOD = {current = 1}
DEBUG = false

allPlayersFrozen = false
paused = false
state = "playing"

KEY_LEFT = "a"
KEY_RIGHT = "d"
KEY_JUMP = "space"
KEY_SWAP = "q"
KEY_RESET = "r"
KEY_QUIT = "f1"

BGM_VOLUME = 0.2
SFX_VOLUME = 1

-- INITAL SETUP -- 
function love.load()
	setupCamera()
	love.filesystem.load("SETTINGS.cfg")()
	bgmStart()
	TEsound.volume("bgm", 0.2)
	TEsound.volume("sfx", 1)

	love.graphics.setBackgroundColor(30,26,29)

	resetLevel()
end

-- GAME LOOP AND INPUT PROCESSING --
function love.update(dt)
	TEsound.cleanup()
	Timer.update(dt)

	if not paused then
		worldUpdate(dt * TIME_MOD.current)
		if not allPlayersFrozen then
			updatePlayers(dt * TIME_MOD.current)
		end

		-- CAMERA --
		cam.tx = -(player.x + player.w/2 + player.xvel/2) + screen.w/2
		cam.ty = -(player.y + player.h/2 + player.yvel/2) + screen.h/2

		cam.x = cam.x + ((cam.tx - cam.x) * cam.speed * dt)
		cam.y = cam.y + ((cam.ty - cam.y) * cam.speed * dt)
	end
end

function love.keypressed(k,code)
	if code == KEY_SWAP then
		nextPlayer()
	end

	if code == "`" then
		DEBUG = not DEBUG
	end

	if code == KEY_RESET then
		resetLevel()
	end

	if code == KEY_QUIT then
		love.event.quit()
	end
end

-- DRAW LOOP --
function love.draw()
	if state == "playing" then
		love.graphics.push()
		love.graphics.translate(cam.x, cam.y)
		love.graphics.scale(cam.scale)
			-- BEHIND PLAYER --
			drawColor()
			drawZones()

			drawText()
			drawPlayers()

			-- OVER PLAYER --
			drawHazards()
			drawBlocks()
		love.graphics.pop()
		
		love.graphics.setColor(255,255,255)

		love.graphics.setFont(smallFont)
		love.graphics.print(love.timer.getFPS(), 5,5)
		love.graphics.print("("..math.floor(cam.x)..", "..math.floor(cam.y)..")", 30,5)
	elseif state == "title" then
		Timer.after(4, function() state = "playing" end)
		love.graphics.setFont(largeFont)
		love.graphics.setColor(200,200,200)
		love.graphics.print("Loophole 2", (screen.w/2) - (largeFont:getWidth("Loophole 2")/2), (screen.h/2) - (largeFont:getHeight("Loophole 2") / 2))
	end
end

function setupCamera()
	screen = {}
	screen.w = love.graphics.getWidth()
	screen.h = love.graphics.getHeight()

	cam = {}
	cam.x = 0
	cam.y = 0
	cam.tx = 0
	cam.ty = 0
	cam.pauseScale = 0.5
	cam.scale = 1

	cam.speed = 2
end