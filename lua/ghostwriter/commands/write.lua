local async = require("ghostwriter.utils.async")
local collections = require("ghostwriter.utils.collections")
local debug = require("ghostwriter.utils.debug")

local config = require("ghostwriter.config")
local slack = require("ghostwriter.slack")
local lib = require("ghostwriter.commands.lib")

local M = {}

function M.exec()
	local cbuf = vim.api.nvim_get_current_buf()

	local lines = vim.api.nvim_buf_get_lines(cbuf, 0, -1, false)
	if #lines == 0 then
		return
	end

	local current_row_no = vim.api.nvim_win_get_cursor(0)[1]
	local base_row_no = collections.find_last_index(vim.list_slice(lines, 1, current_row_no), function(line)
		return line == "---"
	end)
	local start_row_no = base_row_no == nil and 1 or base_row_no + 1

	-- ex: https://minerva.slack.com/archives/C1J80C5MF/p1722259290076499
	local dst = lines[start_row_no]

	-- "---"より前
	local body_lines = collections.head_while(vim.list_slice(lines, start_row_no + 2), "---")

	local contents = lib.normalize_to_slack_message(table.concat(body_lines, "\n"))
	if #contents >= 4000 then
		local error_msg =
			string.format("The message cannot be posted if it exceeds 4000 characters (%d characters)", #contents)
		vim.notify(error_msg, 4)
		return
	end

	local channel_id, ts = slack.pick_channel_and_ts(dst)

	---@async
	async.void(function()
		local notifier = vim.notify("⏳ Writing ...", vim.log.levels.INFO, { timeout = nil })

		if ts then
			local res1 = slack.delete_message(channel_id, ts)
			if not res1.ok then
				error(debug.print_table(res1))
			end
		end

		local res2 = slack.post_message(channel_id, contents)
		if not res2.ok then
			error(debug.print_table(res2))
		end

		async.terminate()

		vim.api.nvim_buf_set_lines(cbuf, start_row_no - 1, start_row_no, false, { res2.channel .. "," .. res2.ts })

		if config.options.autosave then
			vim.cmd("write")
		end

		vim.notify("👻 Write success", vim.log.levels.INFO, { timeout = 1000, replace = notifier })
	end)()
end

return M
