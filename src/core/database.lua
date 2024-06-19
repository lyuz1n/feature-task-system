--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Config = require('tasks/config')
local Task = require('tasks/src/modules/task')

local Database = {
	status = {
		NONE = 'none',
		IN_PROGRESS = 'in_progress',
		PENDING_REWARD = 'pending_reward',
		COMPLETED = 'completed',
		CANCELED = 'canceled'
	}
}

function Database:startup()
	db.query('DELETE FROM feature_tasks_monsters')
	db.query('DELETE FROM feature_tasks_rewards')
	db.query('DELETE FROM feature_tasks')

	for uniqueId, task in pairs(Config.tasks) do
		task.id = uniqueId

		db.query(('INSERT INTO feature_tasks (id, name, kills) VALUES (%d, %s, %d)'):format(
			uniqueId,
			db.escapeString(task.name),
			task.kills
		))

		for _, reward in ipairs(task.rewards) do
			db.query(('INSERT INTO feature_tasks_rewards (task_id, id, count, receive_only_once) VALUES (%d, %d, %d, %d)'):format(
				uniqueId,
				reward.id,
				reward.count,
				reward.first and 1 or 0
			))
		end

		for _, monster in ipairs(task.monsters) do
			db.query(('INSERT INTO feature_tasks_monsters (task_id, name) VALUES (%d, %s)'):format(
				uniqueId,
				db.escapeString(monster)
			))
		end

		Task(uniqueId):fromData(task)
	end
end

function Database:getPlayerInProgressTask(playerGuid)
	local resultId = db.storeQuery(('SELECT id, task_id, current_kills, status FROM feature_tasks_history WHERE player_id = %d AND status IN (%s, %s)'):format(
		playerGuid,
		db.escapeString(self.status.IN_PROGRESS),
		db.escapeString(self.status.PENDING_REWARD)
	))

	if resultId then
		local data = {
			id = result.getString(resultId, 'id'),
			task = Task(result.getNumber(resultId, 'task_id')),
			kills = result.getNumber(resultId, 'current_kills'),
			status = result.getString(resultId, 'status')
		}

		result.free(resultId)
		return data
	end
	return nil
end

function Database:savePlayerInProgressTask(playerTask)
	local data = self:getPlayerInProgressTask(playerTask:getPlayerGuid())

	if data then
		db.query(('UPDATE feature_tasks_history SET current_kills = %d, status = %s WHERE id = %s'):format(
			playerTask:getKills(),
			db.escapeString(playerTask:getStatus()),
			db.escapeString(data.id)
		))
	else
		self:create(playerTask)
	end
end

function Database:create(playerTask)
	db.query(('INSERT INTO feature_tasks_history (id, player_id, task_id, current_kills, status) VALUES (%s, %d, %d, %d, %s)'):format(
		db.escapeString(playerTask:getId()),
		playerTask:getPlayerGuid(),
		playerTask:getTask():getId(),
		playerTask:getKills(),
		db.escapeString(playerTask:getStatus())
	))
end

function Database:updateStatus(id, status)
	db.query(('UPDATE feature_tasks_history SET status = %s WHERE id = %s'):format(
		db.escapeString(status),
		db.escapeString(id)
	))
end

function Database:isTaskFirstCompletion(taskId, playerGuid)
	local resultId = db.storeQuery(('SELECT id FROM feature_tasks_history WHERE task_id = %d AND player_id = %d AND status = %s'):format(
		taskId,
		playerGuid,
		db.escapeString(self.status.COMPLETED)
	))

	if resultId then
		result.free(resultId)
		return false
	end
	return true
end

function Database:getPlayerLastTaskCompletionTime(taskId, playerGuid)
	local resultId = db.storeQuery(('SELECT UNIX_TIMESTAMP(updated_at) AS timestamp FROM feature_tasks_history WHERE player_id = %d AND task_id = %d AND status = %s ORDER BY updated_at DESC LIMIT 1'):format(
		playerGuid,
		taskId,
		db.escapeString(self.status.COMPLETED)
	))

	if resultId then
		local timestamp = result.getNumber(resultId, 'timestamp')
		result.free(resultId)
		return timestamp
	end
	return 0
end

function Database:cleanup(tasks)
	local resultId = db.storeQuery(('SELECT task_id FROM feature_tasks_history WHERE status = %s'):format(
		db.escapeString(self.status.IN_PROGRESS)
	))

	if resultId then
		repeat
			local taskId = result.getNumber(resultId, 'task_id')
			if not tasks[taskId] then
				db.query(('DELETE FROM feature_tasks_history WHERE task_id = %d'):format(
					taskId
				))
			end
		until not result.next(resultId)
		result.free(resultId)
	end
end

return Database
