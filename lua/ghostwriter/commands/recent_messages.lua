local async = require("ghostwriter.utils.async")
local slack = require("ghostwriter.slack")
local debug = require("ghostwriter.utils.debug")
local config = require("ghostwriter.config")
local collections = require("ghostwriter.utils.collections")
local lib = require("ghostwriter.commands.lib")
local picker = require("snacks.picker")

local M = {}

---@param opts {fargs: [string, number?]}
function M.exec(opts)
	local chname = opts.fargs[1]
	local limit = opts.fargs[2] or 20

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
		local res = slack.get_coversations_history(dst.id, limit)
		if not res.ok then
			error(debug.print_table(res))
		end

		async.terminate()

		picker.pick({
			title = chname,
			format = "text",
			items = vim.tbl_map(function(entry)
				local normalized_text = lib.slack_text_to_markdown(entry.text)
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_text(buf, 0, 0, -1, -1, vim.split(normalized_text, "\n"))
				vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

				return {
					text = os.date("%Y-%m-%d %X", tonumber(entry.ts)) .. ": " .. normalized_text,
					buf = buf,
				}
			end, res.messages),
		})
	end)()
end

return M
