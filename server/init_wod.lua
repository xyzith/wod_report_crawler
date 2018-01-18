#! /usr/bin/lua5.3

local redis = require "resty.redis"


function checkReport()
	local red = redis.new()
	local ok, err = red:connect('127.0.0.1', 6379)
	local nextReportTime, err = red:get('wod:time')
	local currentTime = os.time()
	if nextReportTime ~= ngx.null and tonumber(nextReportTime) < os.time() then
		red:del('wod:time')
		os.execute('lua5.3 /home/taylor/tool/wod_report_crawler/localscript/fetchWodLootReport.lua >> /home/taylor/tool/wod_report_crawler/debug.log')
	else 
		ngx.log(ngx.ERR, 'wait timer')
	end
	createTimer()
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
