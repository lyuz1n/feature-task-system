--[[
	Description: Task System
	Author: Lyu
	Discord: lyu07
]]

local Constants = require('tasks/src/core/constants')
local TasksCacheHandler = require('tasks/src/cache/tasks')
local Database = require('tasks/src/core/database')

local globalEvent = GlobalEvent(Constants.GLOBALEVENT_STARTUP)
function globalEvent.onStartup()
	Database:startup()
	Database:cleanup(TasksCacheHandler:getTasks())
	return true
end

globalEvent:register()
