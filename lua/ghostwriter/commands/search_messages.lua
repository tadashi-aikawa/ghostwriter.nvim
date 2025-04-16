local async = require("ghostwriter.utils.async")
local slack = require("ghostwriter.slack")
local debug = require("ghostwriter.utils.debug")
local collections = require("ghostwriter.utils.collections")
local lib = require("ghostwriter.commands.lib")
local picker = require("snacks.picker")

local M = {}

---@param opts {fargs: string[]}
function M.exec(opts)
	local query = table.concat(opts.fargs, " ")
	local count = 20

	-- limit:15 のような形式で指定された場合、limitを取得する
	local limit_pattern = "limit:(%d+)"
	local limit_match = query:match(limit_pattern)
	if limit_match then
		count = assert(tonumber(limit_match))
		query = query:gsub(limit_pattern, ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
	end

	---@async
	async.void(function()
		local res = slack.get_search_messages(query, count, "timestamp")
		if not res.ok then
			error(debug.print_table(res))
		end

		async.terminate()

		local items = {}
		for _, entry in ipairs(res.messages.matches) do
			local normalized_text = lib.slack_text_to_markdown(entry.text)
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_text(buf, 0, 0, -1, -1, vim.split(normalized_text, "\n"))
			vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

			local date = os.date("%Y-%m-%d %X", tonumber(entry.ts))
			table.insert(items, {
				text = string.format("%s: [%s @%s] %s", date, entry.channel.name, entry.username, normalized_text),
				date = date,
				body = normalized_text,
				ts = entry.ts,
				username = entry.username,
				channel_id = entry.channel.id,
				channel_name = entry.channel.name,
				buf = buf,
			})
		end

		--- @type fun(picker: snacks.Picker)
		local confirm = function(_picker)
			local selected_items = _picker:selected({ fallback = true })

			local lines = collections.map(selected_items, function(item)
				return string.format(
					[[
@%s,%s
%s %s @%s

%s
]],
					item.channel_id,
					item.ts,
					item.date,
					item.channel_name,
					item.username,
					item.body
				)
			end)
			local text = table.concat(lines, "\n---\n")

			-- 新しいバッファを作成
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(buf)
			vim.api.nvim_buf_set_text(buf, 0, 0, -1, -1, vim.split(text, "\n"))
			vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
		end

		picker.pick({
			title = query,
			format = "text",
			items = items,
			confirm = confirm,
		})
	end)()
end

return M
