local strings = require("ghostwriter.utils.strings")

local M = {}

local defaults = {
	--- @type boolean
	autosave = true,
	--- @type {mark:string, emoji:string}[]
	check = {
		{ mark = "x", emoji = "large_green_circle" },
		{ mark = " ", emoji = "white_circle" },
	},
	--- @type {emoji:string}
	bullet = {
		emoji = "small_blue_diamond",
	},
	--- @type {ratio:integer}
	indent = {
		ratio = 2,
	},
	--- @type {before_blank_lines:integer}
	header = {
		before_blank_lines = 1,
	},
	--- @type {disabled:boolean}
	link = {
		disabled = false,
	},
	--- @type {pattern:string, replaced:string}[]
	replacers = {},
	--- @type {name:string, id:string}[]
	channel = {},
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", defaults, options)
end

---@param line string
---@param check {mark: string, emoji: string}
---@return string
function M.transform_by_check(line, check)
	local pattern = "[-*] %[" .. strings.escape(check.mark) .. "%] "
	local emoji = ":" .. check.emoji .. ": "
	return strings.replace(line, pattern, emoji)
end

---@param line string
---@param replacer {pattern: string, replaced: string}
---@return string
function M.replace_regexp(line, replacer)
	return strings.replace(line, replacer.pattern, replacer.replaced)
end

return M
