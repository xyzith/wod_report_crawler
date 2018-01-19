#! /usr/bin/lua5.3

local prefix = arg[0]:match('(.-)[^/]+$')
package.path = prefix..'/?.lua;'..package.path

local GUMBO = require 'gumbo'
local ClassList = require 'ClassList'
local bot = require 'telegram_reporter_bot'

function getKey()
	local handle = io.popen('redis-cli get wod:sessId')
	local key = handle:read('*a')
	return key:gsub('\n', '')
end

function getLoginKey()
	local handle = io.popen('redis-cli get wod:login_CC')
	local key = handle:read('*a')
	return key:gsub('\n', '')
end

function fetchReportPage(sessId, login_CC, repotId, postId)
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..sessId..';login_CC='..login_CC..'" -d "report_id[0]='..repotId..'&items[0]=获得物品&wod_post_id='..postId..'" -X POST '..url)
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

function fetchIndexPage(sessId, login_CC)
	local url = 'http://canto.world-of-dungeons.org/wod/spiel/dungeon/report.php?session_hero_id=141623&is_popup=1'
	local handle = io.popen('curl -v --cookie "PHPSESSID='..sessId..';login_CC='..login_CC..'" '..url)
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

function getIds(sessId, login_CC)
	local document = GUMBO.parse(fetchIndexPage(sessId, login_CC))
	local reportId = getLatestReportId(document)
	local postId = getPostId(document)
	return reportId, postId
end

function getTitle(document)
	local title = document:getElementsByTagName('h2')[1]
	if title then
		return title.textContent or ''
	end
	return ''
end

function getLootMessage(sessId, login_CC)
	local reportId, postId = getIds(sessId, login_CC)
	if not reportId or not postId then return nil end
	local document = GUMBO.parse(fetchReportPage(sessId, login_CC, reportId, postId))
	local title = getTitle(document)
	local loots = getUniqueLoot(document)
	local msg = '=='..title..'=='
	for i, loot in ipairs(loots) do
		msg = msg..'\n[item: '..loot..']'
	end
	return msg
end

function run()
	local PHPSESSID = getKey()
	local login_CC = getLoginKey()
	local msg = getLootMessage(PHPSESSID, login_CC) 
	if msg then 
		local ok = bot:init()
		if ok then
			bot:send(msg)
		end
	else
		print('Error: Can\'t fetch data.')
	end
end

run()
