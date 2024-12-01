local async = require("ghostwriter.utils.async")
local slack = require("ghostwriter.slack")
local debug = require("ghostwriter.utils.debug")
local config = require("ghostwriter.config")
local collections = require("ghostwriter.utils.collections")

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
		vim.notify("⏳ Fetching ...", vim.log.levels.INFO, { timeout = 1000 })
		local res = slack.get_coversations_history(dst.id, limit)
		if not res.ok then
			error(debug.print_table(res))
		end

		async.terminate()

		require("telescope.pickers")
			.new({}, {
				prompt_title = "Select a post to insert to the current buffer",
				finder = require("telescope.finders").new_table({
					results = res.messages,
					--- @param entry {text:string, ts:string}
					entry_maker = function(entry)
						return {
							value = entry,
							display = os.date("%Y-%m-%d %X", tonumber(entry.ts)) .. ": " .. entry.text,
							ordinal = entry.text,
						}
					end,
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
				previewer = require("telescope.previewers").new_buffer_previewer({
					define_preview = function(self, entry, status)
						local lines = vim.split(entry.value.text, "\n")
						vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
						vim.wo[self.state.winid].wrap = true
					end,
				}),
				attach_mappings = function(prompt_bufnr)
					local actions = require("telescope.actions")
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						--- @type {value: {text:string, ts:string}}
						local selection = require("telescope.actions.state").get_selected_entry()
						vim.api.nvim_put(vim.split(selection.value.text, "\n"), "", false, true)
					end)
					return true
				end,
			})
			:find()
	end)()
end

return M