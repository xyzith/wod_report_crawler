#! /usr/bin/lua5.3

local ClassList = require './ClassList'
local GUMBO = require 'gumbo'
local Telegram = require 'Telegram'

function dump(table)
	for i,v in pairs(table) do
		io.write(i..'')
		print(v)
	end
end

local PHPSESSID = 'mvrtd9rc043vjrbchjx9m8wthpiu2bem'

function fetchReportPage(sessId, repotId, postId)
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..sessId..'" -d "report_id[0]='..repotId..'&items[0]=获得物品&wod_post_id='..postId..'" -X POST '..url)
	local html = handle:read('*a')
	handle:close()
	return html
end

function getUniqueLoot(document)
	local unique_loots = setmetatable({}, { __index = table })
	local outerTable  = document:getElementsByClassName('content_table')[1]
	if not outerTable then return unique_loots end
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

function fetchIndexPage(sessId)
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..sessId..'" '..url)
	local html = handle:read('*a')
	handle:close()
	return html
end

function getPostId(document)
	local inputs = document:getElementsByTagName('input')
	for i, input in ipairs(inputs) do 
		local name = input:getAttribute('name')
		if name == 'wod_post_id' then
			return input:getAttribute('value')
		end
	end
	return ''

end

function getLatestReportId(document)
	local reportTable  = document:getElementsByClassName('content_table')[1]
	if not reportTable then return '' end
	local latestReportLink = reportTable:getElementsByTagName('input')[1]
	return latestReportLink:getAttribute('value')
end

function getIds(sessId)
	local document = GUMBO.parse(fetchIndexPage(sessId))
	local reportId = getLatestReportId(document)
	local postId = getPostId(document)
	return reportId, postId
end

function getTitle(document)
	local title = document:getElementsByTagName('h2')[1]
	if title then
		return title.textContent
	end
	return 'Error: Can\'t fetch data.'
end

function getLootMessage(sessId)
	local document = GUMBO.parse(fetchReportPage(sessId, getIds(sessId)))
	local title = getTitle(document)
	local loots = getUniqueLoot(document)
	local msg = '=='..title..'=='
	for i, loot in ipairs(loots) do
		msg = msg..'\n[item: '..loot..']'
	end
	return msg
end


local msg = getLootMessage(PHPSESSID) 
Telegram:msg('Dungeon_Master', msg)
--Telegram:msg('Secret_Avangers', msg)
