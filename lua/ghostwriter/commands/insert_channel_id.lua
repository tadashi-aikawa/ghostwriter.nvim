local config = require("ghostwriter.config")
local collections = require("ghostwriter.utils.collections")

local M = {}

---@param opts {fargs: [string]}
function M.exec(opts)
	local chname = opts.fargs[1]

	local dst = collections.find(config.options.channel, function(x)
		return x.name == chname
	end)
	if not dst then
		local error_msg = string.format("'%s' is not defined in the configration -> channel[].name", chname)
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_put({ dst.id }, "", false, true)
end

return M
