local util = require("ghostwriter.util")
local slack = require("ghostwriter.slack")
local config = require("ghostwriter.config")
local collections = require("ghostwriter.collections")
local functions = require("ghostwriter.functions")

local M = {}

local function transform_by_check(line, check)
	local pattern = "[-*] %[" .. util.escape(check.mark) .. "%] "
	local emoji = ":" .. check.emoji .. ": "
	return string.gsub(line, pattern, emoji)
end

local function transform_line(line)
	local r_line = collections.reduce(config.options.check, transform_by_check, line)
	r_line = functions.pipe(r_line, util.convert_header, util.convert_strikethrough, util.convert_link_format)
	return util.scale_indent(r_line, config.options.indent.ratio)
end

function M.post_current_buf()
	local cbuf = vim.api.nvim_get_current_buf()

	local lines = vim.api.nvim_buf_get_lines(cbuf, 0, -1, false)
	if #lines == 0 then
		return
	end

	-- ex: https://minerva.slack.com/archives/C1J80C5MF/p1722259290076499
	local dst = lines[1]

	-- "---"より前
	local body_lines = util.until_delimiter({ unpack(lines, 3) }, "---")
	local in_code_block = false
	for i, line in ipairs(body_lines) do
		if line:match("^```") then
			-- 言語は消す.終わりも引っかかるけどそこは無視
			body_lines[i] = "```"
			in_code_block = not in_code_block
		end

		if not in_code_block then
			body_lines[i] = transform_line(line)
		end
	end

	local contents = table.concat(body_lines, "\n")

	local channel_id, ts = slack.pick_channel_and_ts(dst)

	if ts then
		local res1 = slack.delete_message(channel_id, ts)
		if not res1.ok then
			error(util.print_table(res1, 2))
		end
	end

	local res2 = slack.post_message(channel_id, contents)
	if not res2.ok then
		-- TODO: ここで完了させられる旨を書く
		error(util.print_table(res2, 2))
	end

	vim.api.nvim_buf_set_lines(cbuf, 0, 1, false, { res2.channel .. "," .. res2.ts })
end

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("Ghostwrite", function()
		M.post_current_buf()
		vim.notify("👻 Post success")
	end, { nargs = 0 })
end

return M
