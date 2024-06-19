--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Config = require('tasks/config')
local RepeatIntervalCacheHandler = require('tasks/src/cache/repeat_interval')
local TasksCacheHandler = require('tasks/src/cache/tasks')
local Functions = require('tasks/src/core/functions')
local Texts = require('tasks/src/core/texts')
local Errors = require('tasks/src/core/errors')
local Constants = require('tasks/src/core/constants')
local Database = require('tasks/src/core/database')
local DatabaseStatus = Database.status

local action = Action()
function action.onUse(player)
	local playerTask = TasksCacheHandler:getPlayerTask(player)
	if not playerTask then
		player:sendCancel(Errors.noTaskInProgress)
		return true
	end

	local task = playerTask:getTask()
	if playerTask:getStatus() ~= DatabaseStatus.PENDING_REWARD then
		player:sendCancel(Errors.notCompletedYet:placeholder {
			name = task:getName()
		})
		return true
	end

	local playerGuid = player:getGuid()
	local taskId = task:getId()
	local firstCompletion = Database:isTaskFirstCompletion(taskId, playerGuid)

	Database:updateStatus(playerTask:getId(), DatabaseStatus.COMPLETED)
	Functions:sendRewardsToInbox(player, task, firstCompletion)
	player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
	player:sendAdvanceMessage((firstCompletion and Texts.receivedRewardsFull or Texts.receivedRewards):placeholder {
		name = task:getName(),
		rewards = Functions:getRewardsDescription(task, firstCompletion)
	})

	RepeatIntervalCacheHandler:register(
		playerGuid,
		taskId,
		os.time() + task:getCanRepeatIn():seconds()
	)

	playerTask:delete()
	return true
end

action:uid(Config.rewardChest.uniqueId)
action:register()

local count = 0
local globalEvent = GlobalEvent(Constants.GLOBALEVENT_RECEIVE_REWARDS)
local position = Config.rewardChest.position

local magicEffects = {
	CONST_ME_TUTORIALARROW,
	CONST_ME_GIFT_WRAPS,
	CONST_ME_FIREWORK_BLUE
}

function globalEvent.onThink()
	for _, player in ipairs(Game.getSpectators(position, false, true)) do
		local playerTask = TasksCacheHandler:getPlayerTask(player)
		if playerTask and playerTask:getStatus() == DatabaseStatus.PENDING_REWARD then
			for _, effect in ipairs(magicEffects) do
				position:sendMagicEffect(effect, player)
			end

			count = count + 1
			if count >= 5 then
				count = 0
				player:say(Texts.chestPendingRewards:placeholder {
					name = playerTask:getTask():getName(),
				}, TALKTYPE_MONSTER_SAY, false, player, position)
			end
		end
	end
	return true
end

globalEvent:interval(1200)
globalEvent:register()
