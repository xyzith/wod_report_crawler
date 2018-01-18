local Handler = {}


Handler.__index = Handler

local redis = require 'resty.redis'
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
	local login_CC = ngx.var.arg_login_CC
	red:set('wod:sessId', sessId)
	if time and tonumber(time) > 0 then
		red:set('wod:time', time)
	end
	red:set('wod:login_CC', login_CC)
	ngx.say(red:get('wod:sessId'))
	ngx.say(red:get('wod:time'))
	ngx.say(red:get('wod:login_CC'))
	ngx.exit(200)
	return
end

return M
