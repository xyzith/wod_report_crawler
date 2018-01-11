#! /usr/bin/lua5.3
local ClassList = require './ClassList'
local GUMBO = require 'gumbo'

function dump(table)
	for i,v in pairs(table) do
		io.write(i..'')
		print(v)
	end
end

function curl()
	local PHPSESSID = 'mvrtd9rc043vjrbchjx9m8wthpiu2bem'
	local REPORT_ID = '3647167'
	local POST_ID =  '4wzrc3c7odqr4j7njxcpltds1psrqiag'
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..PHPSESSID..'" -d "report_id[0]='..REPORT_ID..'&items[0]=获得物品&wod_post_id='..POST_ID..'" -X POST '..url)
	local html = handle:read('*a')
	handle:close()
--	print(html)
	return html
end

function getUniqueLoot(document)
	local unique_loots = setmetatable({}, { __index = table })
	local outerTable  = document:getElementsByClassName('content_table')[1]
	if not outerTable then
		return unique_loots
	end
	local charTables = outerTable:getElementsByTagName('table')
	for i, table in ipairs(charTables) do
		-- => tbody => tr
		local table_content = table.childNodes[1].childNodes[1]
		if table_content then
			local loots =  table_content.childNodes[3]
			for i, loot in ipairs(loots:getElementsByTagName('a')) do
				local classList = ClassList:new(loot:getAttribute('class'))
				if classList:contains('item_unique') then
					unique_loots:insert(loot.textContent);
				end
			end
		end
	end
	return unique_loots
end

function getTitle(document)
	local title = document:getElementsByTagName('h2')[1]
	if title then
		return title.textContent
	end
	return 'Error: Can\'t fetch data.'
end

function getLootMessage()
	local document = GUMBO.parse(curl())
	local title = getTitle(document)
	print(title)
	local loots = getUniqueLoot(document)
	local exportString = '=='..title..'=='
	for i, loot in ipairs(loots) do
		exportString = exportString..'\\n[item: '..loot..']'
	end
	return exportString
end

return getLootMessage;
