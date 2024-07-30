local M = {}

function M.print_table(t, indent)
	indent = indent or ""
	for k, v in pairs(t) do
		if type(v) == "table" then
			print(indent .. k .. ":")
			M.print_table(v, indent .. "  ")
		else
			print(indent .. k .. ": " .. tostring(v))
		end
	end
end

function M.until_delimiter(arr, delimiter)
	local result = {}
	for i, value in ipairs(arr) do
		if value == delimiter then
			break
		end
		table.insert(result, value)
	end
	return result
end

function M.scale_indent(line, ratio)
	local leading_spaces = line:match("^%s*")
	local spaces = string.rep(leading_spaces, ratio)
	return spaces .. line:sub(#leading_spaces + 1)
end

function M.convert_link_format(input)
	return input:gsub("%[([^%]]+)%]%(([^%)]+)%)", "<%2|%1>")
end

function M.escape(str)
	-- TODO: ちゃんとした実装
	if str == "-" then
		return "%-"
	end

	return str
end

return M
