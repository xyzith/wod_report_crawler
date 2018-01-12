#! /usr/bin/lua5.3
local prefix = arg[0]:match('(.-)[^/]+$')
package.path = prefix..'/?.lua;'..package.path

local GUMBO = require 'gumbo'
local ClassList = require 'ClassList'
local Telegram = require 'Telegram'

function dump(table)
	for i,v in pairs(table) do
		io.write(i..'')
		print(v)
	end
end

function getKey()
	local handle = io.popen('redis-cli get wod:sessId')
	local key = handle:read('*a')
	return key:gsub('\n', '')
end
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
		return title.textContent or ''
	end
end

function getLootMessage(sessId)
	local reportId, postId = getIds(sessId)
	if not reportId or not postId then return nil end
	local document = GUMBO.parse(fetchReportPage(sessId, reportId, postId))
	local title = getTitle(document)
	local loots = getUniqueLoot(document)
	local msg = '=='..title..'=='
	for i, loot in ipairs(loots) do
		msg = msg..'\n[item: '..loot..']'
	end
	print(reportId, postId, sessId)
	return msg
end

function run()
	print(1)
	local PHPSESSID = getKey()
	print(2)
	local msg = getLootMessage(PHPSESSID) 
	print(3)
	if msg then 
		Telegram:msg('Dungeon_Master', msg)
		--Telegram:msg('Secret_Avangers', msg)
	else
		print('Error: Can\'t fetch data.')
	end
end

run()