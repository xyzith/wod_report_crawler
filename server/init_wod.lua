#! /usr/bin/lua5.3

local redis = require "resty.redis"


function checkReport()
	local red = redis.new()
	local ok, err = red:connect('127.0.0.1', 6379)
	local nextReportTime, err = red:get('wod:time')
	local currentTime = os.time()
	if nextReportTime ~= ngx.null and tonumber(nextReportTime) < os.time() then
		os.execute('lua5.3 /home/lain/app/wod_report_crawler/localscript/fetchWodLootReport.lua')
		red:set('wod:time', getNextTime())
	else 
--		ngx.log(ngx.ERR, 'wait timer')
	end
	createTimer()
end

function getNextTime()
	return os.time() + 7 * 60 * 60 + 300
end

function createTimer()
	local ok, err = ngx.timer.at(300, checkReport)
	if not ok then
		ngx.log(ngx.ERR, 'failed to create timer ', err)
		return
	end
end
if 0 == ngx.worker.id() then
	createTimer()
end
