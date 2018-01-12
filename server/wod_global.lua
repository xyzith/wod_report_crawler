#! /usr/bin/lua5.3

_G.wod = {}

local lastTime = 0

function wod.setTimmer(time) 
	if time - lastTime > 7200 then
		ngx.timer.at()
	end
end

print(os.time())
