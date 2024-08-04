local M = {}

local defaults = {
	check = {
		{ mark = "x", emoji = "large_green_circle" },
		{ mark = " ", emoji = "white_circle" },
	},
	bullet = {
		emoji = "small_blue_diamond",
	},
	indent = {
		ratio = 1,
	},
	autosave = false,
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options)
end

return M
