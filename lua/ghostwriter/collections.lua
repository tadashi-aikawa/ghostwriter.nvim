local M = {}

function M.reduce(tbl, fn, init)
	local acc = init
	for _, v in ipairs(tbl) do
		acc = fn(acc, v)
	end
	return acc
end

return M
