#! /usr/bin/lua5.3

local appPath = '~/app/tg/bin/telegram-cli'
local Telegram = {}

function Telegram:msg(who, msg)
	local command = appPath..' -We '..'\'msg '..who..' "'..self.escapeReturn(msg)..'"\''
	print(command)
	os.execute(command)
end

function Telegram.escapeReturn(text)
	return text:gsub('\n', '\\n')
end

return Telegram
