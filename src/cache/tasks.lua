--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local TasksCacheHandler = {}
local tasks = {}
local playerTasks = {}

function TasksCacheHandler:registerTask(taskId, task)
	tasks[taskId] = task
end

function TasksCacheHandler:getTask(taskId)
	return tasks[taskId]
end

function TasksCacheHandler:getTasks()
	return tasks
end

function TasksCacheHandler:registerPlayerTask(playerGuid, task)
	playerTasks[playerGuid] = task
end

function TasksCacheHandler:unregisterPlayerTask(playerGuid)
	playerTasks[playerGuid] = nil
end

function TasksCacheHandler:getPlayerTask(player)
	return playerTasks[player:getGuid()]
end

return TasksCacheHandler
