local strings = require("ghostwriter.utils.strings")
local collections = require("ghostwriter.utils.collections")
local config = require("ghostwriter.config")

local M = {}

---行を変換する
---@param line string
---@param opts? {skip_convert_link?: boolean}
---@return string
local function transform_line(line, opts)
	local r_line = collections.reduce(config.options.replacers, config.replace_regexp, line)
	r_line = collections.reduce(config.options.check, config.transform_by_check, r_line)
	r_line = strings.replace(r_line, "^(%s*)[-*] (.+)", "%1:" .. config.options.bullet.emoji .. ": %2")
	r_line = strings.convert_header(r_line, config.options.header.before_blank_lines)
	r_line = strings.convert_strong_emphasis(r_line)
	r_line = strings.trim_wikilink(r_line)
	if not (opts and opts.skip_convert_link) then
		r_line = strings.convert_markdown_link(r_line, config.options.link)
	else
		-- 雑過ぎる気はする..
		r_line = strings.replace(r_line, "\\", "")
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
			line = "```"
			in_code_block = not in_code_block
		end

		if in_code_block then
			table.insert(body_lines, line)
		else
			table.insert(body_lines, transform_line(line, opts))
		end
	end

	return table.concat(body_lines, "\n")
end

---Slackが返却するtextの表現をMarkdownに変換します
---@param text string
function M.slack_text_to_markdown(text)
	local lines = vim.split(text, "\n")
	local body_lines = {}

	for _, line in ipairs(lines) do
		-- Code blockの整形
		-- ```\nhoge が ```hoge のように結合されてしまうのを端正
		line = strings.replace(line, "^```(.+)", "```\n%1")
		-- hoge\n``` が hoge``` のように結合されてしまうのを端正
		line = strings.replace(line, "(.+)```$", "%1\n```")

		-- リストの整形
		line = strings.replace(line, "• ", "* ")

		-- リンクの変換
		line = strings.convert_slack_link(line)

		table.insert(body_lines, line)
	end

	return table.concat(body_lines, "\n")
end

return M
