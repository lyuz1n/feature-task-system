--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local TasksCacheHandler = require('tasks/src/cache/tasks')

local Task = {}
Task.__index = Task

function Task:getId() return self.id end

function Task:getName() return self.name end

function Task:getKills() return self.kills end

function Task:getCanRepeatIn() return self.canRepeatIn end

function Task:getMonsters() return self.monsters end

function Task:getRewards() return self.rewards end

function Task:load(data)
	self.id = data.id
	self.name = data.name
	self.kills = data.kills
	self.canRepeatIn = data.canRepeatIn
	self.monsters = data.monsters
	self.rewards = data.rewards
end

function Task:isNotImplemented()
	return self.id == nil
end

return function(uniqueId)
	local task = TasksCacheHandler:getTask(uniqueId)
	if task then
		return task
	end

	local object = { id = uniqueId }
	setmetatable(object, Task)

	TasksCacheHandler:registerTask(uniqueId, object)
	return object
end
