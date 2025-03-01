local async = require("ghostwriter.utils.async")
local slack = require("ghostwriter.slack")
local debug = require("ghostwriter.utils.debug")
local config = require("ghostwriter.config")
local collections = require("ghostwriter.utils.collections")
local lib = require("ghostwriter.commands.lib")

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

		require("telescope.pickers")
			.new({}, {
				prompt_title = "<Select>: yanked(+ register) | <Alt+Enter>: post the query as a slack message",
				results_title = chname,
				finder = require("telescope.finders").new_table({
					results = res.messages,
					--- @param entry {text:string, ts:string}
					entry_maker = function(entry)
						local normalized_text = lib.slack_text_to_markdown(entry.text)
						return {
							value = normalized_text,
							display = os.date("%Y-%m-%d %X", tonumber(entry.ts)) .. ": " .. normalized_text,
							ordinal = entry.text,
						}
					end,
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
				previewer = require("telescope.previewers").new_buffer_previewer({
					define_preview = function(self, entry, status)
						local lines = vim.split(entry.value, "\n")
						vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
						vim.wo[self.state.winid].wrap = true
					end,
				}),
				attach_mappings = function(prompt_bufnr, map)
					local actions = require("telescope.actions")
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						--- @type {value: string}
						local selection = require("telescope.actions.state").get_selected_entry()
						vim.fn.setreg("+", selection.value)
					end)

					local action_state = require("telescope.actions.state")
					map("i", "<M-CR>", function()
						actions.close(prompt_bufnr)
						local query = action_state.get_current_line()

						---@async
						async.void(function()
							local notifier = vim.notify("⏳ Posting ...", vim.log.levels.INFO, { timeout = nil })
							local post_res = slack.post_message(dst.id, query)
							if not post_res.ok then
								error(debug.print_table(post_res))
							end

							async.terminate()
							vim.notify("👻 Post success", vim.log.levels.INFO, { timeout = 1000, replace = notifier })
						end)()
					end)

					return true
				end,
			})
			:find()
	end)()
end

return M
