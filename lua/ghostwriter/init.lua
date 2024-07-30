local util = require("ghostwriter.util")
local slack = require("ghostwriter.slack")
local config = require("ghostwriter.config")

local M = {}

function M.post_current_buf()
	local cbuf = vim.api.nvim_get_current_buf()

	local lines = vim.api.nvim_buf_get_lines(cbuf, 0, -1, false)
	if #lines == 0 then
		return
	end

	-- ex: https://minerva.slack.com/archives/C1J80C5MF/p1722259290076499
	local url = lines[1]

	-- "---"より前
	local body_lines = vim.tbl_map(function(line)
		for _, check in ipairs(config.options.check) do
			local pattern = "- %[" .. check.mark .. "%] "
			local emoji = ":" .. check.emoji .. ": "
			line = string.gsub(line, pattern, emoji)
		end
		line = util.scale_indent(line, config.options.indent.ratio)
		return util.convert_link_format(line)
	end, util.until_delimiter({ unpack(lines, 3) }, "---"))
	local contents = table.concat(body_lines, "\n")

	local channel_id, ts = slack.pick_channel_and_ts(url)

	local res1 = slack.delete_message(channel_id, ts)
	if not res1.ok then
		error(util.print_table(res1, 2))
	end

	local res2 = slack.post_message(channel_id, contents)
	if not res2.ok then
		-- TODO: ここで完了させられる旨を書く
		error(util.print_table(res2, 2))
	end

	vim.api.nvim_buf_set_lines(cbuf, 0, 1, false, { res2.channel .. "," .. res2.ts })
end

-- TODO: optsの追加
function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("Ghostwrite", function()
		vim.api.nvim_echo({ { "Notify to slack ...", "Normal" } }, false, {})
		M.post_current_buf()
		vim.api.nvim_echo({ { "✔️  Success", "Normal" } }, false, {})
	end, { nargs = 0 })
end

return M
