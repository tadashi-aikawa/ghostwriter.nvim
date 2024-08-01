local M = {}

function M.pipe(value, ...)
	local funcs = { ... }
	for _, func in ipairs(funcs) do
		value = func(value)
	end
	return value
end

return M
