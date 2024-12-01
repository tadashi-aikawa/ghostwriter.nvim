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

--- [[wiki link]]を除去する
---@param input string
---@return string
function M.trim_wikilink(input)
	-- [[wikilink]]は予め除外. 完璧ではないがほとんどのケースはカバーできる簡易実装
	return M.replace(input, "%[%[(.+)%]%]", "%1")
end

---MarkdownリンクをSlackの表現に変換する
---@param input string
---@param link {disabled: boolean}
---@return string
function M.convert_markdown_link(input, link)
	local v = input

	v = M.replace(v, "\\%]", "__BRACKET_CLOSE__")
	v = M.replace(v, "\\%[", "__BRACKET_OPEN__")
	v = M.replace(v, "\\%)", "__PARENTHESES_CLOSE__")
	v = M.replace(v, "\\%(", "__PARENTHESES_OPEN__")
	v = M.replace(v, "\\%-", "__HYPHEN__")

	if link.disabled then
		v = M.replace(v, "%[([^%]]+)%]%(([^%)]+)%)", "%1")
	else
		v = M.replace(v, "%[([^%]]+)%]%(([^%)]+)%)", "<%2|%1>")
	end

	v = M.replace(v, "__BRACKET_CLOSE__", "]")
	v = M.replace(v, "__BRACKET_OPEN__", "[")
	v = M.replace(v, "__PARENTHESES_CLOSE__", ")")
	v = M.replace(v, "__PARENTHESES_OPEN__", "(")
	v = M.replace(v, "__HYPHEN__", "-")

	return v
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

---SlackリンクをMarkdownリンクの表現に変換する
---@param input string
---@return string
function M.convert_slack_link(input)
	local v = input

	v = M.replace(v, "<(http[^|]+)|([^>]+)>", "[%2](%1)")
	v = M.replace(v, "<(http[^>]+)>", "%1")

	return v
end

return M
