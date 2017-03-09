blocks = {}
zones = {}
hazards = {}
TIMER_DEFAULT = 1

local text = {}
local coloredAreas = {}

local PLAYABLE_AREA_COLOR = {214,213,213,255}

local CURRENT_LEVEL = 1

function worldUpdate(dt)
	-- ZONES --
	doneZones = 0

	for i,v in ipairs(zones) do
		v.alpha = 100 * v.timer

		if v.done then
			doneZones = doneZones + 1
		end
	end

	if doneZones == #zones then 
		nextLevel()
	end

	-- TEXT --
	for i,v in ipairs(text) do
		if not v.done then
			v.timer = v.timer - dt

			if v.timer <= 0 then
				v.done = true
			elseif v.timer <= 1 then
				v.alpha = 100 * (1 - v.timer)
			end
		end
	end

	-- ZONES --
	for i,v in ipairs(zones) do
		for k,b in ipairs(players) do
			if (not v.done) and v.playerID == b.id then
				if BoundingBox(b.x,b.y,b.w,b.h, v.x,v.y,v.w,v.h) then
					v.timer = v.timer - dt

					if v.timer <= 0 then
						v.done = true
					end
				else
					if v.timer ~= TIMER_DEFAULT and not v.done then
						v.timer = TIMER_DEFAULT
					end
				end
			end
		end
	end
end

function addBlock(x,y,w,h)
	bl = {}
	bl.x = x
	bl.y = y
	bl.w = w
	bl.h = h

	table.insert(blocks, bl)
end

function addHazard(x,y,w,h)
	bl = {}
	bl.x = x
	bl.y = y
	bl.w = w
	bl.h = h

	table.insert(hazards, bl)
end

function addText(x,y,str, size, timer)
	bl = {}
	bl.x = x
	bl.y = y
	bl.str = str
	bl.size = size
	bl.timer = timer
	bl.done = false
	bl.alpha = 255

	table.insert(text, bl)
end

function addZone(x,y,w,h, ID)
	bl = {}
	bl.x = x
	bl.y = y
	bl.w = w
	bl.h = h

	bl.alpha = 100
	bl.timer = TIMER_DEFAULT
	bl.done = false

	bl.playerID = ID

	table.insert(zones, bl)
end

function addColor(x,y,w,h)
	bl = {}
	bl.x = x
	bl.y = y
	bl.w = w
	bl.h = h

	table.insert(coloredAreas, bl)
end

function drawBlocks()
	if DEBUG then
		love.graphics.setColor(255,255,255)

		for i,v in ipairs(blocks) do
			love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
		end
	end
end

function drawColor()
	love.graphics.setColor(PLAYABLE_AREA_COLOR)
	for i,v in ipairs(coloredAreas) do
		love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
	end
end

function drawZones()
	for i,v in ipairs(zones) do
		love.graphics.setColor(PLAYER_COLOR[v.playerID][1],PLAYER_COLOR[v.playerID][2],PLAYER_COLOR[v.playerID][3], v.alpha)
		love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
	end	

	love.graphics.setColor(255,255,255,255)
end

function drawHazards()
	for i,v in ipairs(hazards) do
		love.graphics.setColor(84,8,4)
		love.graphics.rectangle("fill", v.x,v.y, v.w,v.h)
	end	
end

function drawText()
	for i,v in ipairs(text) do
		if v.timer <= 0.99 then
			love.graphics.setColor(255,255,255, v.alpha)

			if v.size == "small" then
				love.graphics.setFont(smallFont)
			else 
				love.graphics.setFont(mainFont)
			end

			love.graphics.print(v.str, v.x,v.y)
		end
	end	

	love.graphics.setColor(255,255,255, 255)
end

function resetLevel()
	TIME_MOD.current = 1
	clearPlayers()
	blocks = {}
	zones = {}
	coloredAreas = {}
	text = {}
	hazards = {}
	Timer.clear()

	loadLevel(CURRENT_LEVEL)
end

function loadLevel(n)
	chunk = love.filesystem.load("levels/LEVEL_"..n)()
end

function nextLevel()
	CURRENT_LEVEL = CURRENT_LEVEL + 1
	resetLevel()
end

function BoundingBox(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end