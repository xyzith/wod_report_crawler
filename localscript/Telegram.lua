#! /usr/bin/lua5.3

local appPath = '/home/taylor/app/tg/bin/telegram-cli'
local Telegram = {}

function Telegram:msg(who, msg)
	local command = appPath..' -WERCe '..'\'msg '..who..' "'..self.escapeReturn(msg)..'"\''
	print(command)
	os.execute(command)
end

function Telegram.escapeReturn(text)
	return text:gsub('\n', '\\n')
end

return Telegram
