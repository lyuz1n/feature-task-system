--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local TasksCacheHandler = require('tasks/src/cache/tasks')

local PlayerTask = {}
PlayerTask.__index = PlayerTask

function PlayerTask:get() return TasksCacheHandler:getPlayerTask(self.playerGuid) end
function PlayerTask:getTask() return self.task end
function PlayerTask:getPlayerGuid() return self.playerGuid end
function PlayerTask:getId() return self.id end
function PlayerTask:getKills() return self.kills end
function PlayerTask:getStatus() return self.status end
function PlayerTask:setStatus(status) self.status = status end

function PlayerTask:load(data)
	TasksCacheHandler:registerPlayerTask(self.playerGuid, self)
	self.id = data.id
	self.task = data.task
	self.kills = data.kills
	self.status = data.status
end

function PlayerTask:delete()
	TasksCacheHandler:unregisterPlayerTask(self.playerGuid)
end

return function(player)
	local object = {playerGuid = player:getGuid()}

	setmetatable(object, PlayerTask)
	return object
end
