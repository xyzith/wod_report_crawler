#! /usr/bin/lua5.3

local redis = require "resty.redis"

_G.wod = {}

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
	ngx.timer.at(60, checkReport)
end


if 0 == ngx.worker.id() then
	ngx.timer.at(60, checkReport)
end
