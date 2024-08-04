local async = require("ghostwriter.utils.async")
local strings = require("ghostwriter.utils.strings")
local collections = require("ghostwriter.utils.collections")
local debug = require("ghostwriter.utils.debug")

local config = require("ghostwriter.config")
local slack = require("ghostwriter.slack")

local M = {}

---@param line string
---@param check {mark: string, emoji: string}
---@return string
local function transform_by_check(line, check)
	local pattern = "[-*] %[" .. strings.escape(check.mark) .. "%] "
	local emoji = ":" .. check.emoji .. ": "
	return strings.replace(line, pattern, emoji)
end

---@param line string
---@return string
local function transform_line(line)
	local r_line = collections.reduce(config.options.check, transform_by_check, line)
	r_line = strings.replace(r_line, "(%s*)[-*] (.+)", "%1:" .. config.options.bullet.emoji .. ":%2")
	r_line = strings.convert_header(r_line, config.options.header.before_blank_lines)
	r_line = strings.convert_link(r_line)
	r_line = strings.scale_indent(r_line, config.options.indent.ratio)
	return r_line
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
	local body_lines = collections.head_while({ unpack(lines, 3) }, "---")
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

	---@async
	async.void(function()
		local notifier = vim.notify("⏳ Posting...", vim.log.levels.INFO, { timeout = nil })

		if ts then
			local res1 = slack.delete_message(channel_id, ts)
			if not res1.ok then
				error(debug.print_table(res1))
			end
		end

		vim.notify(contents)
		local res2 = slack.post_message(channel_id, contents)
		if not res2.ok then
			error(debug.print_table(res2))
		end

		async.terminate()

		vim.api.nvim_buf_set_lines(cbuf, 0, 1, false, { res2.channel .. "," .. res2.ts })

		if config.options.autosave then
			vim.cmd("write")
		end

		vim.notify("👻 Post success", vim.log.levels.INFO, { timeout = 1000, replace = notifier })
	end)()
end

function M.setup(opts)
	config.setup(opts)
	vim.api.nvim_create_user_command("Ghostwrite", M.post_current_buf, { nargs = 0 })
end

return M
