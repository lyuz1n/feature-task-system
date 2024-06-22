--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Errors = require('tasks/src/core/errors')

local Functions = {}

function Functions:getMonstersDescription(task)
	local monsters = {}

	for index, monster in ipairs(task.monsters) do
		monsters[#monsters + 1] = ('%s%s%s'):format(
			monster,
			task.kills > 1 and 's' or '',
			index < (#task.monsters - 1) and ', ' or (index == #task.monsters) and '' or ' or '
		)
	end
	return table.concat(monsters)
end

function Functions:getRewardsDescription(task, firstCompletion)
	local rewards = {}
	local taskRewards = task:getRewards()

	for index, reward in ipairs(taskRewards) do
		local canInsert = true
		if reward.first and not firstCompletion then
			canInsert = false
		end

		if canInsert then
			local itemType = ItemType(reward.id)
			rewards[#rewards + 1] = ('%d %s%s'):format(
				reward.count,
				reward.count > 1 and itemType:getPluralName() or itemType:getName(),
				index < (#taskRewards - 1) and ', ' or (index == #taskRewards) and '' or ' and '
			)
		end
	end
	return table.concat(rewards):lower()
end

function Functions:sendRewardsToInbox(player, task, firstCompletion)
	local inbox = player:getInbox()
	if not inbox then
		player:sendCancel(Errors.defaultError)
		return
	end

	for _, reward in ipairs(task:getRewards()) do
		local skipAdd = reward.first and not firstCompletion
		if not skipAdd then
			inbox:addItem(reward.id, reward.count, INDEX_WHEREEVER, FLAG_NOLIMIT)
		end
	end
end

return Functions
