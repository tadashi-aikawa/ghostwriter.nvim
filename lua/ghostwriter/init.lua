local config = require("ghostwriter.config")
local write = require("ghostwriter.commands.write")
local post = require("ghostwriter.commands.post")
local copy = require("ghostwriter.commands.copy")
local collections = require("ghostwriter.utils.collections")

local M = {}

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("GhostwriterWrite", write.exec, { nargs = 0 })
	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })

	vim.api.nvim_create_user_command("GhostwriterPost", post.exec, {
		nargs = 1,
		range = true,
		complete = function()
			return collections.map(config.options.channel, function(ch)
				return ch.name
			end)
		end,
	})
end

return M
