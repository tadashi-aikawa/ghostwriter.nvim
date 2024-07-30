local M = {}

local defaults = {
	check = {
		{ mark = "x", emoji = "large_green_circle" },
		{ mark = " ", emoji = "white_circle" },
	},
	indent = {
		ratio = 1,
	},
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options)
end

return M
