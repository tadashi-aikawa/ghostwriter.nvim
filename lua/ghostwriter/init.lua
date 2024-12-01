local config = require("ghostwriter.config")
local write = require("ghostwriter.commands.write")
local post = require("ghostwriter.commands.post")
local copy = require("ghostwriter.commands.copy")
local insert_channel_id = require("ghostwriter.commands.insert_channel_id")
local recent_messages = require("ghostwriter.commands.recent_messages")
local collections = require("ghostwriter.utils.collections")

local M = {}

function M.setup(opts)
	config.setup(opts)

	local channel_name_completion = function(_, cmdline, _)
		local args = vim.split(cmdline, "%s+")
		if #args == 2 then
			return collections.map(config.options.channel, function(ch)
				return ch.name
			end)
		end

		return {}
	end

	vim.api.nvim_create_user_command("GhostwriterWrite", write.exec, { nargs = 0 })
	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })

	vim.api.nvim_create_user_command("GhostwriterPost", post.exec, {
		nargs = "+",
		range = true,
		complete = channel_name_completion,
	})

	vim.api.nvim_create_user_command("GhostwriterInsertChannelID", insert_channel_id.exec, { nargs = 0 })
	vim.api.nvim_create_user_command("GhostwriterRecentMessages", recent_messages.exec, {
		nargs = "+",
		complete = channel_name_completion,
	})
end

return M
