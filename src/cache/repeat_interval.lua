--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Database = require('tasks/src/core/database')

local RepeatIntervalCacheHandler = {}
local intervals = {}

function RepeatIntervalCacheHandler:getSecondsRemaining(playerGuid, taskId)
	local taskInterval = intervals[playerGuid]
	if not taskInterval then
		return 0
	end

	taskInterval = taskInterval[taskId]
	if not taskInterval then
		return 0
	end

	return math.max(0, taskInterval - os.time())
end

function RepeatIntervalCacheHandler:register(playerGuid, taskId, timestamp)
	intervals[playerGuid] = intervals[playerGuid] or {}
	intervals[playerGuid][taskId] = timestamp
end

function RepeatIntervalCacheHandler:clear(player)
	intervals[player:getGuid()] = nil
end

function RepeatIntervalCacheHandler:registerAll(player, tasks)
	for taskId, task in pairs(tasks) do
		local lastCompletionTime = Database:getPlayerLastTaskCompletionTime(taskId, player:getGuid())
		if lastCompletionTime > 0 then
			lastCompletionTime = lastCompletionTime + task:getCanRepeatIn():seconds()
		end

		self:register(
			player:getGuid(),
			taskId,
			lastCompletionTime
		)
	end
end

function RepeatIntervalCacheHandler:getIntervals()
	return intervals
end

return RepeatIntervalCacheHandler
