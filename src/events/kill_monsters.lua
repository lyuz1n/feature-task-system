--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Texts = require('tasks/src/core/texts')
local Constants = require('tasks/src/core/constants')
local Database = require('tasks/src/core/database')
local DatabaseStatus = Database.status

local function isValidMonster(monsters, monsterName)
	for _, name in ipairs(monsters) do
		if name:lower() == monsterName:lower() then
			return true
		end
	end
	return false
end

local creatureEvent = CreatureEvent(Constants.CREATUREEVENT_KILL)
function creatureEvent.onKill(player, target)
	if not target:isMonster() then
		return true
	end
	
	local playerTask = PlayerTask(player):get()
	if not playerTask then
		return true
	end

	local task = playerTask:getTask()
	if not task or not isValidMonster(task:getMonsters(), target:getName()) or playerTask:getKills() >= task:getKills() then
		return true
	end

	playerTask.kills = playerTask.kills + 1
	player:sendBlueMessage(Texts.progress:placeholder {
		name = task:getName(),
		currentkills = playerTask:getKills(),
		kills = task:getKills()
	})
	
	if playerTask:getKills() < task:getKills() then
		return true
	end

	playerTask:setStatus(DatabaseStatus.PENDING_REWARD)
	Database:savePlayerInProgressTask(playerTask)
	player:unregisterEvent(Constants.CREATUREEVENT_KILL)
	player:sendAdvanceMessage(Texts.completed:placeholder {
		name = task:getName()
	})
	return true
end

creatureEvent:register()
