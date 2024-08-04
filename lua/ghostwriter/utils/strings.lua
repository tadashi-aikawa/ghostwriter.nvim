local M = {}

---文字列を正規表現パターンで置換する
---@param str string
---@param pattern string
---@param repl string
---@return string
function M.replace(str, pattern, repl)
	local r, _ = string.gsub(str, pattern, repl)
	return r
end

---indentをratio倍に増幅する
---@param line string
---@param ratio number
---@return string
function M.scale_indent(line, ratio)
	local leading_spaces = line:match("^ +")
	if leading_spaces == nil then
		return line
	end

	local spaces = string.rep(leading_spaces, ratio)
	return spaces .. line:sub(#leading_spaces + 1)
end

---MarkdownリンクをSlackの表現に変換する
---@param input string
---@return string
function M.convert_link(input)
	return M.replace(input, "%[([^%]]+)%]%(([^%)]+)%)", "<%2|%1>")
end

---MarkdownヘッダをSlackの表現に変換する
---@param input string
---@param before_blank_lines? number
---@return string
function M.convert_header(input, before_blank_lines)
	local blank_lines = string.rep("\n", before_blank_lines or 0)
	return M.replace(input, "^#+ (.+)", blank_lines .. "*%1*")
end

---正規表現用にエスケープする
---@param str string
---@return string
function M.escape(str)
	-- TODO: ちゃんとした実装
	if str == "-" then
		return "%-"
	end

	return str
end

return M
