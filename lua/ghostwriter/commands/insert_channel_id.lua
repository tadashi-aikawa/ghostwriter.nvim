local config = require("ghostwriter.config")

local M = {}

function M.exec()
	require("telescope.pickers")
		.new({}, {
			prompt_title = "Choose channel name",
			finder = require("telescope.finders").new_table({
				results = config.options.channel,
				--- @param entry {name:string, id:string}
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = require("telescope.config").values.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				local actions = require("telescope.actions")
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					--- @type {value: {name:string, id:string}}
					local selection = require("telescope.actions.state").get_selected_entry()
					vim.api.nvim_put({ selection.value.id }, "", false, true)
				end)
				return true
			end,
		})
		:find()
end

return M
