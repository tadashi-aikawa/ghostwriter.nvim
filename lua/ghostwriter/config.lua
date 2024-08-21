local M = {}

local defaults = {
	autosave = true,
	check = {
		{ mark = "x", emoji = "large_green_circle" },
		{ mark = " ", emoji = "white_circle" },
	},
	bullet = {
		emoji = "small_blue_diamond",
	},
	indent = {
		ratio = 2,
	},
	header = {
		before_blank_lines = 1,
	},
	link = {
		disabled = false,
	},
	replacers = {},
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options)
end

return M
