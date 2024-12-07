local async = require("ghostwriter.utils.async")
local slack = require("ghostwriter.slack")
local debug = require("ghostwriter.utils.debug")
local editor = require("ghostwriter.utils.editor")
local lib = require("ghostwriter.commands.lib")
local config = require("ghostwriter.config")
local collections = require("ghostwriter.utils.collections")

local M = {}

---@param opts {fargs: [string, string?]}
function M.exec(opts)
	local chname = opts.fargs[1]
	local mode = opts.fargs[2]

	local text = editor.get_visual_selection()
	if mode == "code" then
		text = "```\n" .. text .. "\n```"
	elseif mode then
		vim.notify("⛔ Invalid mode name: " .. mode, vim.log.levels.ERROR)
		return
	end

	local message = lib.normalize_to_slack_message(text)
	if #message >= 4000 then
		local error_msg =
			string.format("The message cannot be posted if it exceeds 4000 characters (%d characters)", #message)
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	local dst = collections.find(config.options.channel, function(x)
		return x.name == chname
	end)
	if not dst then
		local error_msg = string.format("'%s' is not defined in the configration -> channel[].name", chname)
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end

	---@async
	async.void(function()
		local notifier = vim.notify("⏳ Posting ...", vim.log.levels.INFO, { timeout = nil })
		local res = slack.post_message(dst.id, message)
		if not res.ok then
			error(debug.print_table(res))
		end

		async.terminate()
		vim.notify("👻 Post success", vim.log.levels.INFO, { timeout = 1000, replace = notifier })
	end)()
end

return M
