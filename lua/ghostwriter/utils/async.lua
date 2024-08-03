local async = require("plenary.async")
local curl = require("plenary.curl")

local M = {}

---diagnosticが必ず表示されてしまう問題の回避策
---@param func async fun()
---@return function
function M.void(func)
	---@diagnostic disable-next-line: not-yieldable
	return async.void(func)
end

---非同期処理を終了する
function M.terminate()
	async.util.scheduler()
end

M.get = async.wrap(function(opts, callback)
	opts.callback = callback
	curl.get(opts)
end, 2)

M.post = async.wrap(function(opts, callback)
	opts.callback = callback
	curl.post(opts)
end, 2)

return M
