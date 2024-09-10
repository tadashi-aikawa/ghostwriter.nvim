local config = require("ghostwriter.config")
local ghostwrite = require("ghostwriter.commands.ghostwrite")
local copy = require("ghostwriter.commands.copy")

local M = {}

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("Ghostwrite", ghostwrite.exec, { nargs = 0 })

	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })
end

return M
