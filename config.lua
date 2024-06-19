--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

return {
	rewardChest = {
		uniqueId = 14300,
		position = Position(2222, 941, 7)
	},

	tasks = {
		[14301] = {
			name = 'Dungeons and Dragons',
			monsters = {'Dragon', 'Dragon Lord'},
			kills = 5,
			canRepeatIn = Duration {minutes = 30},
			rewards = {
				{id = 8205, count = 1, first = true},
				{id = 9971, count = 7},
				{id = 7366, count = 20}
			}
		},
	
		[14302] = {
			name = 'Demons and Deaths',
			monsters = {'Demon'},
			kills = 5,
			canRepeatIn = Duration {minutes = 30},
			rewards = {
				{id = 9971, count = 5, first = true},
				{id = 2160, count = 50}
			}
		}
	}
}
