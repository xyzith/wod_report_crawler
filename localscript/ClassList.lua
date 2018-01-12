#! /usr/bin/lua5.3

local ClassList = {}

function ClassList:__index(key)
	if key == 'list' then
		return self:getList()
	end

	return ClassList[key]
end

function ClassList:remove(name)
	local result = setmetatable({}, { __index = table })
	for k,v in ipairs(self.list) do
		if v ~= name then
			result:insert(v)
		end
	end
	self.str = result:concat(' ')
end

function ClassList:contains(name)
	for k,v in ipairs(self.list) do
		if v == name then
			return true
		end
	end
	return false
end

function ClassList:add(name)
	if not self:contains(name) then
		local tmp = self.list
		tmp:insert(name)
		self.str = tmp:concat(' ')
	end
end

function ClassList:new(str)
	local new = setmetatable({}, self)
	new.str = str
	return new
end

function ClassList:getList()
	local str = self.str
	local list = setmetatable({}, { __index = table })
	for i in str:gmatch("%S+") do
		list:insert(i)
	end
	return list
end

return ClassList
