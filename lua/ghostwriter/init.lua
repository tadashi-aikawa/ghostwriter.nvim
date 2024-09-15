local config = require("ghostwriter.config")
local write = require("ghostwriter.commands.write")
local copy = require("ghostwriter.commands.copy")

local M = {}

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("GhostwriterWrite", write.exec, { nargs = 0 })

	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })
end

return M
