local editor = require("ghostwriter.utils.editor")
local lib = require("ghostwriter.commands.lib")

local M = {}

function M.exec()
	local text = editor.get_visual_selection()
	local slack_message = lib.normalize_to_slack_message(text, { skip_convert_link = true })
	vim.fn.setreg("+", slack_message)
end

return M
