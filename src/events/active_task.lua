--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Config = require('tasks/config')
local Functions = require('tasks/src/core/functions')
local Texts = require('tasks/src/core/texts')
local Errors = require('tasks/src/core/errors')
local RepeatIntervalCacheHandler = require('tasks/src/cache/repeat_interval')
local PlayerTask = require('tasks/src/modules/player_task')
local Task = require('tasks/src/modules/task')
local Constants = require('tasks/src/core/constants')
local Database = require('tasks/src/core/database')
local DatabaseStatus = Database.status

local action = Action()
function action.onUse(player, item)
	local task = Task(item:getUniqueId())

	if task:isNotImplemented() then
		player:sendCancel(Errors.notFound)
		return true
	end

	local playerTask = PlayerTask(player):get()
	if playerTask then
		local status = playerTask:getStatus()
		local task = playerTask:getTask()

		if status == DatabaseStatus.IN_PROGRESS then
			player:sendCancel(Errors.cancelBeforeStart:placeholder {
				name = task:getName(),
				command = Constants.TAKACTION_WORDS
			})
		elseif status == DatabaseStatus.PENDING_REWARD then
			player:sendCancel(Errors.receiveRewardBeforeStart:placeholder {
				name = task:getName()
			})
		end
		return true
	end

	local seconds = RepeatIntervalCacheHandler:getSecondsRemaining(player:getGuid(), task:getId())
	if seconds > 0 then
		player:sendCancel(Errors.canRepeatTaskIn:placeholder {
			duration = Duration {seconds = seconds}:string(Constants.DURATION_LANGUAGE)
		})
		return true
	end

	local playerTask = PlayerTask(player):load {
		id = uuid(),
		task = task,
		kills = 0,
		status = DatabaseStatus.IN_PROGRESS
	}

	Database:create(playerTask)

	local firstCompletion = Database:isTaskFirstCompletion(task:getId(), player:getGuid())
	player:sendAdvanceMessage((firstCompletion and Texts.startedFirstTime or Texts.started):placeholder {
		name = task:getName(),
		kills = task:getKills(),
		monsters = Functions:getMonstersDescription(task),
		rewards = Functions:getRewardsDescription(task, firstCompletion)
	})

	player:registerEvent(Constants.CREATUREEVENT_KILL)
	return true
end

for uniqueId in pairs(Config.tasks) do
	action:uid(uniqueId)
end

action:register()
