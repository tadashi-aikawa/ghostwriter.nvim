local config = require("ghostwriter.config")
local write = require("ghostwriter.commands.write")
local post = require("ghostwriter.commands.post")
local copy = require("ghostwriter.commands.copy")
local recent_messages = require("ghostwriter.commands.recent_messages")
local collections = require("ghostwriter.utils.collections")

local M = {}

--- @alias completion_type
--- | '"channel_name"'
--- | '"mode"'

function M.setup(opts)
	config.setup(opts)

	--- @type fun(completion_type: completion_type): string[]
	local create_suggestions = function(complection_type)
		if complection_type == "channel_name" then
			return collections.map(config.options.channel, function(ch)
				return ch.name
			end)
		end
		if complection_type == "mode" then
			return { "code" }
		end

		error("Invalid completion_type")
	end

	--- @type fun(completion_types: completion_type[]): function
	local create_completion = function(completion_types)
		return function(_, cmdline, _)
			local args = vim.split(cmdline, "%s+")

			if #args == 2 and completion_types[1] then
				return create_suggestions(completion_types[1])
			end

			if #args == 3 and completion_types[2] then
				return create_suggestions(completion_types[2])
			end

			return {}
		end
	end

	vim.api.nvim_create_user_command("GhostwriterWrite", write.exec, { nargs = 0 })
	vim.api.nvim_create_user_command("GhostwriterCopy", copy.exec, { nargs = 0, range = true })

	vim.api.nvim_create_user_command("GhostwriterPost", post.exec, {
		nargs = "+",
		range = true,
		complete = create_completion({ "channel_name", "mode" }),
	})

	vim.api.nvim_create_user_command("GhostwriterRecentMessages", recent_messages.exec, {
		nargs = "+",
		complete = create_completion({ "channel_name" }),
	})
end

return M
