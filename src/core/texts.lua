--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

return {
	clearSuccess = [[
		[Task System]
		Task {name} successfully ended. You can now start another task.
	]],

	startedFirstTime = [[
		[Task System]
		You have started the task {name} for the first time.
		To complete it, you need to hunt {kills} {monsters}.
		Your reward upon completion will be:
		{rewards}.
	]],

	started = [[
		[Task System]
		You have started the task {name}.
		To complete it, you need to hunt {kills} {monsters}.
		Your reward upon completion will be:
		{rewards}.
	]],

	completed = [[
		[Task System]
		You have successfully completed the task {name}.
		Go to the task room and open the chest to receive your reward.
	]],

	receivedRewardsFull = [[
		[Task System]
		You have received your full reward for completing the task for the first time.
		Task: {name}.
		Reward: {rewards}.
	]],

	receivedRewards = [[
		[Task System]
		You have received a reduced reward for repeating the task.
		Task: {name}.
		Reward: {rewards}.
	]],

	loginPendingRewards = [[
		[Task System]
		You have a pending reward for completing the task {name}.
		To claim it, go to the task room and open the chest.
	]],

	chestPendingRewards = [[
		Click on this chest to receive your reward for completing the {name} task.
	]],

	progress = [[
		[{name}]: {currentkills} out of {kills} have been hunted.
	]]
}
