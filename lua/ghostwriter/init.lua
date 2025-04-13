local config = require("ghostwriter.config")
local write = require("ghostwriter.commands.write")
local post = require("ghostwriter.commands.post")
local copy = require("ghostwriter.commands.copy")
local recent_messages = require("ghostwriter.commands.recent_messages")
local search_messages = require("ghostwriter.commands.search_messages")
local collections = require("ghostwriter.utils.collections")

local M = {}

--- @alias completion_type
--- | '"channel_name"'
--- | '"mode"'
--- | '"query"'

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
		if complection_type == "query" then
			return {
				"limit:15",
				"in:times_hogehoge",
				"from:me",
				"search_exclude_bots=false",
				"on:today",
				"on:yesterday",
				"before:2025-01-01",
				"after:2025-01-01",
			}
		end

		error("Invalid completion_type")
	end

	--- @type fun(completion_types: completion_type[], rest_default?: completion_type): function
	local create_completion = function(completion_types, rest_default)
		return function(_, cmdline, _)
			local cmd_parts = vim.split(cmdline, "%s+", { trimempty = true })
			table.remove(cmd_parts, 1)

			if #cmd_parts == 0 and completion_types[1] then
				return create_suggestions(completion_types[1])
			end

			if #cmd_parts == 1 and completion_types[2] then
				return create_suggestions(completion_types[2])
			end

			if rest_default then
				return create_suggestions(rest_default)
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
	vim.api.nvim_create_user_command("GhostwriterSearchMessages", search_messages.exec, {
		nargs = "+",
		complete = create_completion({ "query" }, "query"),
	})
end

return M
