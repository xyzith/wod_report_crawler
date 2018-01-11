#! /usr/bin/lua5.3
local ClassList = require 'ClassList'
local GUMBO = require 'gumbo'

function dump(table)
	for i,v in pairs(table) do
		io.wirte(i..'')
		print(v)
	end
end

function curl()
	local PHPSESSID = 'krnpt28p4yxmj5qei1vrqdsqcbzxep1a'
	local REPORT_ID = '3638832'
	local POST_ID =  '02acgfavwvw9vk7w18ds019xhpt731np'
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..PHPSESSID..'" -d "report_id[0]='..REPORT_ID..'&items[0]=获得物品&wod_post_id='..POST_ID..'" -X POST '..url)
	local html = handle:read('*a')
	handle:close()
	return html
end

function getLoot(document)
	local outerTable  = document:getElementsByClassName('content_table')[1]
	if not outerTable then
		return ''
	end
	dump(document);
	dump(outerTable)
	local charTables = outerTable:getElementsByTagName('table')
	print(charTables.length)
end

local document = GUMBO.parse(curl())
local loots = getLoot(document)

--[[
for i, el in ipairs(document.links) do
	local class = el:getAttribute('class');
	class = setmetatable(class, { __index = DomClass})
	print(class:classList());
	print(el:getAttribute('href'))
end
]]--

--[[
local class = ClassList:new('afd sdfsd ddff')
for i,v in ipairs(class.list) do
	print(v)
end

class:add('agggg')
print(class.str)
class:add('afd')
print(class.str)
class:remove('afd')
print(class.str)
]]--

