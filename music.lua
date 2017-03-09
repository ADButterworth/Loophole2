local CURRENT_BGM = 1
local BGM_STATE = "intro"

function bgmStart()
	BGM_STATE = "intro"
	TEsound.play("bgm/"..CURRENT_BGM.."-start.ogg", {"bgm"}, 1, 1, bgmLoop)
end

function bgmLoop()
	if BGM_STATE == "intro" or BGM_STATE == "looping" then
		BGM_STATE = "looping"
		TEsound.play("bgm/"..CURRENT_BGM.."-loop.ogg", {"bgm"}, 1, 1, bgmLoop)
	elseif BGM_STATE == "stopping" then
		TEsound.play("bgm/"..CURRENT_BGM.."-end.ogg", {"bgm"}, 1, 1)
	end
end

function bgmStop()
	BGM_STATE = "stopping"
end