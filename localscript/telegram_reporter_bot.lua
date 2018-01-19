local M = {}

function getToken()
	local handle = io.popen('redis-cli get wod:token')
	local key = handle:read('*a')
	return key:gsub('\n', '')
end

function M:init()
	local text = arg[1]
	local token = getToken()
	print(token);

	if not token then
		print('No token')
		return false
	end

	self.api = require('telegram-bot-lua.core').configure(token)
	return true
end

function M:send(msg)
--	local chat_id = 186794921 -- my id
	local chat_id = -1001080958213 -- channel
	self.api.send_message(chat_id, msg, 'HTML')
end

return M
