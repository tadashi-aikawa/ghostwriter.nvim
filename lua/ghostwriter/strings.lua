local M = {}

-- indentをratio倍に増幅する
function M.scale_indent(line, ratio)
	local leading_spaces = line:match("^%s*")
	local spaces = string.rep(leading_spaces, ratio)
	return spaces .. line:sub(#leading_spaces + 1)
end

-- MarkdownリンクをSlackの表現に変換する
function M.convert_link(input)
	return input:gsub("%[([^%]]+)%]%(([^%)]+)%)", "<%2|%1>")
end

-- MarkdownヘッダをSlackの表現に変換する
function M.convert_header(input)
	return input:gsub("^#+ (.+)", "*%1*")
end

-- 正規表現用にエスケープする
function M.escape(str)
	-- TODO: ちゃんとした実装
	if str == "-" then
		return "%-"
	end

	return str
end

return M
