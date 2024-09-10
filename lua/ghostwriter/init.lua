local config = require("ghostwriter.config")
local post = require("ghostwriter.commands.post")
local copy = require("ghostwriter.commands.copy")

local M = {}

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("GhostwriterPost", post.exec, { nargs = 0 })

	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })
end

return M
