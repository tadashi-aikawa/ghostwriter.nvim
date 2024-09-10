local strings = require("ghostwriter.utils.strings")
local collections = require("ghostwriter.utils.collections")
local config = require("ghostwriter.config")

local M = {}

---@param line string
---@param opts? {skip_convert_link?: boolean}
---@return string
local function transform_line(line, opts)
	local r_line = collections.reduce(config.options.replacers, config.replace_regexp, line)
	r_line = collections.reduce(config.options.check, config.transform_by_check, r_line)
	r_line = strings.replace(r_line, "^(%s*)[-*] (.+)", "%1:" .. config.options.bullet.emoji .. ": %2")
	r_line = strings.convert_header(r_line, config.options.header.before_blank_lines)
	r_line = strings.trim_wikilink(r_line)
	if not (opts and opts.skip_convert_link) then
		r_line = strings.convert_link(r_line, config.options.link)
	end
	r_line = strings.scale_indent(r_line, config.options.indent.ratio)
	return r_line
end

---MarkdownをSlackのメッセージに適した形に標準化します
---@param markdown_text string
---@param opts? {skip_convert_link?: boolean}
---@return string
function M.normalize_to_slack_message(markdown_text, opts)
	local lines = vim.split(markdown_text, "\n")
	local in_code_block = false
	local body_lines = {}

	for _, line in ipairs(lines) do
		if line:match("^```") then
			-- 言語は消す.終わりも引っかかるけどそこは無視
			table.insert(body_lines, "```")
			in_code_block = not in_code_block
		end

		if not in_code_block then
			table.insert(body_lines, transform_line(line, opts))
		end
	end

	return table.concat(body_lines, "\n")
end

return M
