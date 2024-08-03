local async = require("plenary.async")

local M = {}

---@param value any
---@vararg fun(arg: any): any
---@return any
function M.pipe(value, ...)
	local funcs = { ... }
	for _, func in ipairs(funcs) do
		value = func(value)
	end
	return value
end

---diagnosticが必ず表示されてしまう問題の回避策
---@param func async fun()
function M.async(func)
	---@diagnostic disable-next-line: not-yieldable
	async.void(func)
end

return M
