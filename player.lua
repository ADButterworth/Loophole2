-- CONSTANTS -- 
local PLAYER_WIDTH = 20
local PLAYER_HEIGHT = 40
local WALK_VEL = 187
local WALK_ACCEL = WALK_VEL * 3
local FRICTION = WALK_VEL * 5
local GRAV = 500
local JUMP_VEL = -337
local JUMP_TIME = 1.5

PLAYER_COLOR = {{242,84,91}, {85,214,190}, {157,173,111}, {164,145,211}}

-- VAR --
players = {}
player = {}
activePlayerID = 1
local nextPlayerID = 2

-- FUNCTIONS --
function addPlayer(x,y)
	pl = {}
	pl.x = x
	pl.y = y
	pl.w = PLAYER_WIDTH
	pl.h = PLAYER_HEIGHT

	pl.xvel = 0
	pl.yvel = 0

	pl.id = #players + 1

	-- JUMPING --
	pl.onGround = false
	pl.grounded = false
	pl.jumpTimeLeft = 0
	pl.falling = true
	-- /JUMPING --

	table.insert(players, pl)
end

function drawPlayers()
	for i,v in ipairs(players) do
		love.graphics.setColor(PLAYER_COLOR[i][1], PLAYER_COLOR[i][2], PLAYER_COLOR[i][3])
		love.graphics.rectangle("fill", v.x,v.y,v.w,v.h)

		if i == activePlayerID then
			love.graphics.setColor(39,39,39)
			love.graphics.circle("fill", math.floor(v.x + v.w/2), math.floor(v.y + v.h/3), 4, 50)
		end

		if i == nextPlayerID then
			love.graphics.setColor(39,39,39)
			love.graphics.circle("line", math.floor(v.x + v.w/2), math.floor(v.y + v.h/3), 4, 50)
		end
	end

	if DEBUG then
		love.graphics.setColor(255,255,255)
		love.graphics.print("x:"..players[activePlayerID].x, 5-cam.x, 15-cam.y)
		love.graphics.print("y:"..players[activePlayerID].y, 5-cam.x, 25-cam.y)
		love.graphics.print("xvel:"..players[activePlayerID].xvel, 5-cam.x, 35-cam.y)
		love.graphics.print("yvel:"..players[activePlayerID].yvel, 5-cam.x, 45-cam.y)
	end

	love.graphics.setColor(255,255,255)
end

function updatePlayers(dt)
	player = {}
	player = players[activePlayerID]

	-- H MOVEMENT --
	if love.keyboard.isScancodeDown(KEY_RIGHT) and not love.keyboard.isScancodeDown(KEY_LEFT) then
		if (player.xvel + WALK_ACCEL * dt) < WALK_VEL then
			if player.xvel < 0 then
				player.xvel = player.xvel + (WALK_ACCEL * 3) * dt
			else
				player.xvel = player.xvel + WALK_ACCEL * dt
			end
		else
			player.xvel = WALK_VEL
		end
	elseif love.keyboard.isScancodeDown(KEY_LEFT) and not love.keyboard.isScancodeDown(KEY_RIGHT) then
		if (player.xvel - WALK_ACCEL * dt) > -WALK_VEL then
			if player.xvel > 0 then
				player.xvel = player.xvel - (WALK_ACCEL * 3) * dt
			else
				player.xvel = player.xvel - WALK_ACCEL * dt
			end
		else
			player.xvel = -WALK_VEL
		end
	else
		if player.xvel ~= 0 then
			if (player.xvel + FRICTION * dt) < 0 then
				player.xvel = player.xvel + FRICTION * dt
			elseif (player.xvel - FRICTION * dt) > 0 then
				player.xvel = player.xvel - FRICTION * dt
			else
				player.xvel = 0
			end
		end
	end

	-- V MOVEMENT --
	if player.onGround and love.keyboard.isScancodeDown(KEY_JUMP) then
		player.falling = false
		player.onGround = false
		player.jumpTimeLeft = JUMP_TIME
	end

	if (not player.onGround) and (not player.falling) then
		player.jumpTimeLeft = player.jumpTimeLeft - dt
		if (player.jumpTimeLeft < 0) or not love.keyboard.isScancodeDown(KEY_JUMP) then
			player.falling = true
		end
	end

	if not player.onGround then
		if player.falling then		
			player.yvel = player.yvel + (GRAV + (player.jumpTimeLeft * GRAV)) * dt
		else
			player.yvel = JUMP_VEL + (JUMP_TIME - player.jumpTimeLeft) * -JUMP_VEL
		end
	end

	-- PLAYER -> WORLD COL --
	player.grounded = false
	playerToBlockCol(dt)
	playerToPlayerCol(dt)
	player.onGround = player.grounded

	-- HAZARDS --
	for i,v in ipairs(hazards) do
		if BoundingBox(player.x, player.y, player.w, player.h, v.x,v.y,v.w,v.h) then
			resetLevel()
		end			
	end

	-- MOVE PLAYER POS --
	player.x = math.floor(player.x + player.xvel * dt)
	player.y = math.floor(player.y + player.yvel * dt)
end

function playerToBlockCol(dt)
	local player = players[activePlayerID]

	for i,v in ipairs(blocks) do
		if (player.x + player.w) > v.x and player.x < (v.x + v.w)  then
			if ((player.y + player.h) <= v.y) and ((player.y + player.h + player.yvel * dt) >= v.y) and not player.onGround then
				TEsound.play("sfx/land.ogg", {"sfx"}, clamp(0, player.yvel / (GRAV * 2), 1), 1) -- landing sound

				player.yvel = 0
				player.onGround = true
				player.y = v.y - player.h
				print("P:B COL FOUND (B -> T)")
			end

			if (player.y >= v.y + v.h) and ((player.y + player.yvel * dt) <= v.y + v.h) then
				player.yvel = 0
				player.falling = true
				player.y = v.y + v.h
				print("P:B COL FOUND (T -> B)")
			end

			if player.y + player.h == v.y then
				player.grounded = true
			end
		end

		if (player.y + player.h) > v.y and player.y < (v.y + v.h) then
			if (player.x + player.w) <= v.x then
				if (player.x + player.w + player.xvel * dt) > v.x then
					player.x = v.x - player.w
					player.xvel = 0
					print("P:B COL FOUND (R -> L)")
				end
			elseif player.x >= (v.x + v.w) then
				if (player.x + player.xvel * dt) < (v.x + v.w) then
					player.x = v.x + v.w
					player.xvel = 0
					print("P:B COL FOUND (L -> R)")
				end
			end
		end
	end
end

function playerToPlayerCol(dt)
	local player = players[activePlayerID]

	for i,v in ipairs(players) do
		if i ~= activePlayerID then
			if (player.x + player.w) > v.x and player.x < (v.x + v.w)  then
				if (player.y + player.h) < v.y then
					if (player.y + player.h + player.yvel * dt) > v.y then
						TEsound.play("sfx/land.ogg", {"sfx"}, clamp(0, player.yvel / (GRAV * 2), 1), 1) -- landing sound

						player.yvel = 0
						player.onGround = true
						player.y = v.y - player.h
						print("P:P COL FOUND (B -> T)")
					end
				end

				if player.y + player.h == v.y then
					player.grounded = true
				end
			end
		end
	end
end

function nextPlayer()
	if #players > 1 then
		activePlayerID = nextPlayerID
		nextPlayerID = nextPlayerID + 1

		if nextPlayerID > #players then
			nextPlayerID = 1
		end

		if math.pow(math.pow(players[activePlayerID].xvel, 2) + math.pow(players[activePlayerID].yvel, 2), 0.5) > 50 then
			TIME_MOD.current = 0
			Timer.tween(3, TIME_MOD, {current = 1}, "in-linear")
		end
	end
end

function clearPlayers()
	players = {}
	activePlayerID = 1
	nextPlayerID = 2
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end