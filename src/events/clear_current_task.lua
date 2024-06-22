--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local TasksCacheHandler = require('tasks/src/cache/tasks')
local Texts = require('tasks/src/core/texts')
local Errors = require('tasks/src/core/errors')
local Constants = require('tasks/src/core/constants')
local Database = require('tasks/src/core/database')
local DatabaseStatus = Database.status

local talkAction = TalkAction(Constants.TAKACTION_WORDS)
function talkAction.onSay(player, words, param)
	param = param:lower()
	if not param or param:empty() or param ~= 'clear' then
		player:sendCancel(Errors.useClearParam:placeholder {
			command = Constants.TAKACTION_WORDS
		})
		return false
	end

	local playerTask = TasksCacheHandler:getPlayerTask(player)
	if not playerTask then
		player:sendCancel(Errors.noTaskInProgress)
		return false
	end

	if playerTask:getStatus() == DatabaseStatus.PENDING_REWARD then
		player:sendCancel(Errors.receiveRewardFirst)
		return false
	end

	local name = playerTask:getTask():getName()
	Database:updateStatus(playerTask:getId(), DatabaseStatus.CANCELED)
	playerTask:delete()

	player:sendAdvanceMessage(Texts.clearSuccess:placeholder {
		name = name
	})
end

talkAction:separator(' ')
talkAction:register()
