local Handler = {}

Handler.__index = Handler

function Handler:setSessId(id)
	self:set('wod:sessId', id)
end

function Handler:getSessId()
	local value, err = self:get('wod:sessId')
	return value
end

function Handler:getTime(id)
	local value, err = self:get('wod:time')
	return value
end

function Handler:setTimer(time)
	self:set('wod:timer', id)
end

local redis = setmetatable(require "resty.redis", Handler)
local M = {}

function M.run()

	ngx.header['Access-Control-Allow-Origin'] = '*'
	ngx.header['Content-Type'] = 'text/plain'

	local red = redis:new()
	local ok, err = red:connect('127.0.0.1', 6379)
	if err then
		ngx.say('connect redis error '..err)
		ngx.exit(500)
		return
	end
	local sessId = ngx.var.arg_key
	local time = ngx.var.arg_time
	red:setSessId(sessId)
	ngx.say(red:getSessId())
	ngx.say(time)
	os.execute('lua5.3 /home/taylor/tool/wod_report_crawler/localscript/fetchWodLootReport.lua >> /home/taylor/tool/wod_report_crawler/debug.log')
	ngx.exit(200)
	return
end

return M
