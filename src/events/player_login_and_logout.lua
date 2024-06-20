--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local TasksCacheHandler = require('tasks/src/cache/tasks')
local RepeatIntervalCacheHandler = require('tasks/src/cache/repeat_interval')
local PlayerTask = require('tasks/src/modules/player_task')
local Constants = require('tasks/src/core/constants')
local Texts = require('tasks/src/core/texts')
local Database = require('tasks/src/core/database')
local DatabaseStatus = Database.status

local creatureEvent = CreatureEvent(Constants.CREATUREEVENT_LOGIN)
function creatureEvent.onLogin(player)
	RepeatIntervalCacheHandler:registerAll(player, TasksCacheHandler:getTasks())

	local playerGuid = player:getGuid()
	local data = Database:getPlayerInProgressTask(playerGuid)
	if not data then
		return true
	end

	local playerTask = PlayerTask(player)
	playerTask:load(data)

	local task = playerTask:getTask()
	local status = playerTask:getStatus()

	if status == DatabaseStatus.IN_PROGRESS then
		player:registerEvent(Constants.CREATUREEVENT_KILL)
	elseif status == DatabaseStatus.PENDING_REWARD then
		player:sendAdvanceMessage(Texts.loginPendingRewards:placeholder {
			name = task:getName()
		})
	end
	return true
end

creatureEvent:register()

creatureEvent = CreatureEvent(Constants.CREATUREEVENT_LOGOUT)
function creatureEvent.onLogout(player)
	RepeatIntervalCacheHandler:clear(player)

	local playerTask = PlayerTask(player):get()
	if not playerTask then
		return true
	end
	
	Database:savePlayerInProgressTask(playerTask)
	playerTask:delete()
	return true
end

creatureEvent:register()
